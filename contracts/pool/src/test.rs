#![cfg(test)]

use soroban_sdk::{testutils::Address as _, Address, Env, BytesN};
use crate::{PoolContract, PoolContractClient};

fn create_contract<'a>(env: &'a Env) -> (PoolContractClient<'a>, Address) {
    let contract_address = env.register_contract(None, PoolContract);
    let client = PoolContractClient::new(&env, &contract_address);
    (client, contract_address)
}

#[test]
fn test_initialize() {
    let env = Env::default();
    env.mock_all_auths();
    let (client, _) = create_contract(&env);
    let admin = Address::generate(&env);

    client.initialize(&admin);

    // Should fail on second init
    let result = client.try_initialize(&admin);
    assert!(result.is_err());
}

#[test]
fn test_deposit() {
    let env = Env::default();
    env.mock_all_auths();
    let (client, _) = create_contract(&env);
    let admin = Address::generate(&env);

    client.initialize(&admin);

    let sender = Address::generate(&env);
    let amount: i128 = 1_000_000_000;
    let commitment = BytesN::<32>::from_array(&env, &[1u8; 32]);

    let index = client.deposit(&sender, &amount, &commitment);
    assert_eq!(index, 0);

    let next = client.get_next_index();
    assert_eq!(next, 1);
}

#[test]
fn test_deposit_invalid_amount() {
    let env = Env::default();
    env.mock_all_auths();
    let (client, _) = create_contract(&env);
    let admin = Address::generate(&env);

    client.initialize(&admin);

    let sender = Address::generate(&env);
    let commitment = BytesN::<32>::from_array(&env, &[1u8; 32]);

    // Zero amount
    let result = client.try_deposit(&sender, &0, &commitment);
    assert!(result.is_err());

    // Negative amount
    let result = client.try_deposit(&sender, &-1, &commitment);
    assert!(result.is_err());
}

#[test]
fn test_transfer() {
    let env = Env::default();
    env.mock_all_auths();
    let (client, _) = create_contract(&env);
    let admin = Address::generate(&env);

    client.initialize(&admin);

    // First deposit
    let sender = Address::generate(&env);
    let amount: i128 = 1_000_000_000;
    let commitment = BytesN::<32>::from_array(&env, &[1u8; 32]);
    client.deposit(&sender, &amount, &commitment);

    // Transfer
    let nullifier = BytesN::<32>::from_array(&env, &[2u8; 32]);
    let new_commitment = BytesN::<32>::from_array(&env, &[3u8; 32]);

    client.transfer(&nullifier, &new_commitment);

    let next = client.get_next_index();
    assert_eq!(next, 2);
}

#[test]
fn test_double_spend_prevention() {
    let env = Env::default();
    env.mock_all_auths();
    let (client, _) = create_contract(&env);
    let admin = Address::generate(&env);

    client.initialize(&admin);

    // Deposit
    let sender = Address::generate(&env);
    let amount: i128 = 1_000_000_000;
    let commitment = BytesN::<32>::from_array(&env, &[1u8; 32]);
    client.deposit(&sender, &amount, &commitment);

    // First transfer
    let nullifier = BytesN::<32>::from_array(&env, &[2u8; 32]);
    let new_commitment = BytesN::<32>::from_array(&env, &[3u8; 32]);
    client.transfer(&nullifier, &new_commitment);

    // Second transfer with same nullifier should fail
    let result = client.try_transfer(&nullifier, &new_commitment);
    assert!(result.is_err());
}

#[test]
fn test_withdraw() {
    let env = Env::default();
    env.mock_all_auths();
    let (client, _) = create_contract(&env);
    let admin = Address::generate(&env);

    client.initialize(&admin);

    // Deposit
    let sender = Address::generate(&env);
    let amount: i128 = 1_000_000_000;
    let commitment = BytesN::<32>::from_array(&env, &[1u8; 32]);
    client.deposit(&sender, &amount, &commitment);

    // Withdraw
    let recipient = Address::generate(&env);
    let nullifier = BytesN::<32>::from_array(&env, &[2u8; 32]);

    client.withdraw(&recipient, &nullifier, &amount);

    // Nullifier should be spent
    let spent = client.is_nullifier_spent(&nullifier);
    assert!(spent);
}

#[test]
fn test_get_commitment() {
    let env = Env::default();
    env.mock_all_auths();
    let (client, _) = create_contract(&env);
    let admin = Address::generate(&env);

    client.initialize(&admin);

    let sender = Address::generate(&env);
    let amount: i128 = 1_000_000_000;
    let commitment = BytesN::<32>::from_array(&env, &[1u8; 32]);
    client.deposit(&sender, &amount, &commitment);

    let stored = client.get_commitment(&0);
    assert_eq!(stored, commitment);
}
