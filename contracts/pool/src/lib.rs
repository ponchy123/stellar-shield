#![no_std]

use soroban_sdk::{
    contract, contractimpl, contracterror, contracttype,
    symbol_short, Address, Bytes, BytesN, Env, Map, Vec,
};

/// 合约错误类型
#[contracterror]
#[derive(Copy, Clone, Debug, Eq, PartialEq, PartialOrd, Ord)]
#[repr(u32)]
pub enum Error {
    NotAuthorized = 1,
    MerkleTreeFull = 2,
    AlreadyInitialized = 3,
    WrongExtAmount = 5,
    InvalidProof = 6,
    AlreadySpentNullifier = 8,
    NotInitialized = 10,
}

/// 存储键
#[contracttype]
#[derive(Clone, Debug, Eq, PartialEq)]
pub enum DataKey {
    Admin,
    Nullifiers,
    Commitments,
}

/// 隐私池合约
#[contract]
pub struct PoolContract;

#[contractimpl]
impl PoolContract {
    pub fn initialize(env: Env, admin: Address) -> Result<(), Error> {
        if env.storage().persistent().has(&DataKey::Admin) {
            return Err(Error::AlreadyInitialized);
        }
        env.storage().persistent().set(&DataKey::Admin, &admin);
        env.storage()
            .persistent()
            .set(&DataKey::Nullifiers, &Map::<BytesN<32>, bool>::new(&env));
        env.storage()
            .persistent()
            .set(&DataKey::Commitments, &Map::<i128, BytesN<32>>::new(&env));
        env.storage().instance().set(&symbol_short!("IDX"), &0i128);
        Ok(())
    }

    pub fn deposit(
        env: Env,
        sender: Address,
        amount: i128,
        commitment: BytesN<32>,
    ) -> Result<i128, Error> {
        sender.require_auth();
        if amount <= 0 {
            return Err(Error::WrongExtAmount);
        }
        let index: i128 = env.storage().instance().get(&symbol_short!("IDX")).unwrap_or(0);
        let mut commitments = Self::get_commitments(&env)?;
        commitments.set(index, commitment);
        Self::set_commitments(&env, &commitments);
        env.storage().instance().set(&symbol_short!("IDX"), &(index + 1));
        Ok(index)
    }

    pub fn transfer(
        env: Env,
        nullifier_hash: BytesN<32>,
        new_commitment: BytesN<32>,
    ) -> Result<(), Error> {
        let nulls = Self::get_nullifiers(&env)?;
        if nulls.get(nullifier_hash.clone()).unwrap_or(false) {
            return Err(Error::AlreadySpentNullifier);
        }
        let mut nulls = Self::get_nullifiers(&env)?;
        nulls.set(nullifier_hash, true);
        Self::set_nullifiers(&env, &nulls);
        let index: i128 = env.storage().instance().get(&symbol_short!("IDX")).unwrap_or(0);
        let mut commitments = Self::get_commitments(&env)?;
        commitments.set(index, new_commitment);
        Self::set_commitments(&env, &commitments);
        env.storage().instance().set(&symbol_short!("IDX"), &(index + 1));
        Ok(())
    }

    pub fn withdraw(
        env: Env,
        to: Address,
        nullifier_hash: BytesN<32>,
        _amount: i128,
    ) -> Result<(), Error> {
        let nulls = Self::get_nullifiers(&env)?;
        if nulls.get(nullifier_hash.clone()).unwrap_or(false) {
            return Err(Error::AlreadySpentNullifier);
        }
        let mut nulls = Self::get_nullifiers(&env)?;
        nulls.set(nullifier_hash, true);
        Self::set_nullifiers(&env, &nulls);
        Ok(())
    }

    pub fn get_next_index(env: Env) -> i128 {
        env.storage().instance().get(&symbol_short!("IDX")).unwrap_or(0)
    }

    pub fn is_nullifier_spent(env: Env, nullifier: BytesN<32>) -> Result<bool, Error> {
        let nulls = Self::get_nullifiers(&env)?;
        Ok(nulls.get(nullifier).unwrap_or(false))
    }

    pub fn get_commitment(env: Env, index: i128) -> Result<BytesN<32>, Error> {
        let commitments = Self::get_commitments(&env)?;
        commitments.get(index).ok_or(Error::NotInitialized)
    }

    fn get_nullifiers(env: &Env) -> Result<Map<BytesN<32>, bool>, Error> {
        env.storage().persistent().get(&DataKey::Nullifiers).ok_or(Error::NotInitialized)
    }

    fn set_nullifiers(env: &Env, m: &Map<BytesN<32>, bool>) {
        env.storage().persistent().set(&DataKey::Nullifiers, m);
    }

    fn get_commitments(env: &Env) -> Result<Map<i128, BytesN<32>>, Error> {
        env.storage().persistent().get(&DataKey::Commitments).ok_or(Error::NotInitialized)
    }

    fn set_commitments(env: &Env, m: &Map<i128, BytesN<32>>) {
        env.storage().persistent().set(&DataKey::Commitments, m);
    }
}

#[cfg(test)]
mod test;
