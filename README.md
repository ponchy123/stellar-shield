# StellarShield

> Zero-Knowledge Privacy Protocol on Stellar

A privacy-preserving transfer protocol built on Stellar using zero-knowledge proofs. Users can deposit, transfer, and withdraw tokens while keeping transaction amounts and identities private.

## Live Demo

- **Testnet Contract**: `CB2YBHCTTPLHQ5ZDY3Z25M5V6RP23SIG5PLPWCUIQVJYBA23TU3FKFGX`
- **Explorer**: [View on Stellar Expert](https://stellar.expert/explorer/testnet/contract/CB2YBHCTTPLHQ5ZDY3Z25M5V6RP23SIG5PLPWCUIQVJYBA23TU3FKFGX)

## How It Works

1. **Deposit**: User deposits tokens and creates a commitment (hash of amount + secret)
2. **Transfer**: User spends an existing commitment and creates a new one (nullifier prevents double-spending)
3. **Withdraw**: User proves knowledge of a commitment and withdraws tokens

## Architecture

```
┌─────────────────────────────────────────┐
│           Frontend (HTML/JS)            │
│  ┌─────────┐  ┌──────────┐  ┌────────┐ │
│  │Freighter │  │ snarkjs  │  │ Stellar│ │
│  │ Wallet   │  │ (ZK proofs)│ │ SDK    │ │
│  └─────────┘  └──────────┘  └────────┘ │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│      Stellar Blockchain (Testnet)       │
│  ┌─────────────────────────────────┐   │
│  │   Privacy Pool Contract          │   │
│  │   - Commitment storage           │   │
│  │   - Nullifier tracking           │   │
│  │   - Balance proofs               │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│         ZK Circuit (Circom)             │
│  ┌─────────────────────────────────┐   │
│  │   Balance Proof Circuit          │   │
│  │   - Poseidon hashing             │   │
│  │   - Merkle proof verification    │   │
│  │   - Range proofs                 │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

## Tech Stack

- **ZK Circuit**: Circom 2.2.3
- **Proof System**: Groth16
- **Blockchain**: Stellar (Soroban)
- **Smart Contract**: Rust (Soroban SDK 26)
- **Frontend**: HTML/CSS/JavaScript
- **Wallet**: Freighter

## Project Structure

```
stellar-shield/
├── circuits/
│   ├── balance_proof.circom        # ZK circuit
│   ├── balance_proof.r1cs          # R1CS constraints
│   ├── balance_proof_final.zkey    # Proving key
│   └── verification_key.json       # Verification key
├── contracts/
│   └── pool/
│       ├── src/lib.rs              # Smart contract
│       └── Cargo.toml              # Dependencies
├── frontend/
│   ├── index.html                  # UI
│   └── app.js                      # Logic
└── README.md
```

## Getting Started

### Prerequisites

- [Freighter Wallet](https://www.freighter.app/) browser extension
- Stellar Testnet account with XLM

### Run Locally

```bash
cd frontend
python -m http.server 8000
# Open http://localhost:8000
```

### Deploy Contract

```bash
# Build contract
stellar contract build --manifest-path contracts/pool/Cargo.toml

# Deploy to testnet
stellar contract deploy \
  --wasm contracts/pool/target/wasm32v1-none/release/stellar_shield_pool.wasm \
  --source-account admin \
  -- --admin <ADMIN_ADDRESS>
```

## Circuit Details

The ZK circuit proves:
1. **Balance >= MinBalance**: Range proof without revealing exact balance
2. **Merkle Proof**: Commitment exists in the Merkle tree
3. **Nullifier**: Prevents double-spending of commitments

### Constraints

- Non-linear constraints: 5,882
- Linear constraints: 6,307
- Public inputs: 3
- Private inputs: 42
- Wires: 12,231

## Innovation Points

1. **Client-side proofs**: ZK proofs generated in the browser
2. **Nullifier mechanism**: Prevents double-spending without revealing identity
3. **Commitment scheme**: Hides transaction amounts and parties
4. **Stellar-native**: Built on Soroban smart contracts

## Demo Script

See [demo-script.md](demo-script.md) for the 2-3 minute demo video script.

## License

MIT
