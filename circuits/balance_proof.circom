pragma circom 2.0.0;

include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/mux1.circom";

// 简化的 Merkle 证明模板（固定 20 层）
template MerkleProof20() {
    signal input leaf;
    signal input pathElements[20];
    signal input pathIndices[20];
    signal output root;

    component hashers[20];
    component muxL[20];
    component muxR[20];
    signal intermediateHashes[21];
    intermediateHashes[0] <== leaf;

    // 第 0 层
    muxL[0] = Mux1();
    muxL[0].c[0] <== intermediateHashes[0];
    muxL[0].c[1] <== pathElements[0];
    muxL[0].s <== pathIndices[0];

    muxR[0] = Mux1();
    muxR[0].c[0] <== pathElements[0];
    muxR[0].c[1] <== intermediateHashes[0];
    muxR[0].s <== pathIndices[0];

    hashers[0] = Poseidon(2);
    hashers[0].inputs[0] <== muxL[0].out;
    hashers[0].inputs[1] <== muxR[0].out;
    intermediateHashes[1] <== hashers[0].out;

    // 第 1 层
    muxL[1] = Mux1();
    muxL[1].c[0] <== intermediateHashes[1];
    muxL[1].c[1] <== pathElements[1];
    muxL[1].s <== pathIndices[1];

    muxR[1] = Mux1();
    muxR[1].c[0] <== pathElements[1];
    muxR[1].c[1] <== intermediateHashes[1];
    muxR[1].s <== pathIndices[1];

    hashers[1] = Poseidon(2);
    hashers[1].inputs[0] <== muxL[1].out;
    hashers[1].inputs[1] <== muxR[1].out;
    intermediateHashes[2] <== hashers[1].out;

    // 第 2 层
    muxL[2] = Mux1();
    muxL[2].c[0] <== intermediateHashes[2];
    muxL[2].c[1] <== pathElements[2];
    muxL[2].s <== pathIndices[2];

    muxR[2] = Mux1();
    muxR[2].c[0] <== pathElements[2];
    muxR[2].c[1] <== intermediateHashes[2];
    muxR[2].s <== pathIndices[2];

    hashers[2] = Poseidon(2);
    hashers[2].inputs[0] <== muxL[2].out;
    hashers[2].inputs[1] <== muxR[2].out;
    intermediateHashes[3] <== hashers[2].out;

    // 第 3 层
    muxL[3] = Mux1();
    muxL[3].c[0] <== intermediateHashes[3];
    muxL[3].c[1] <== pathElements[3];
    muxL[3].s <== pathIndices[3];

    muxR[3] = Mux1();
    muxR[3].c[0] <== pathElements[3];
    muxR[3].c[1] <== intermediateHashes[3];
    muxR[3].s <== pathIndices[3];

    hashers[3] = Poseidon(2);
    hashers[3].inputs[0] <== muxL[3].out;
    hashers[3].inputs[1] <== muxR[3].out;
    intermediateHashes[4] <== hashers[3].out;

    // 第 4 层
    muxL[4] = Mux1();
    muxL[4].c[0] <== intermediateHashes[4];
    muxL[4].c[1] <== pathElements[4];
    muxL[4].s <== pathIndices[4];

    muxR[4] = Mux1();
    muxR[4].c[0] <== pathElements[4];
    muxR[4].c[1] <== intermediateHashes[4];
    muxR[4].s <== pathIndices[4];

    hashers[4] = Poseidon(2);
    hashers[4].inputs[0] <== muxL[4].out;
    hashers[4].inputs[1] <== muxR[4].out;
    intermediateHashes[5] <== hashers[4].out;

    // 第 5 层
    muxL[5] = Mux1();
    muxL[5].c[0] <== intermediateHashes[5];
    muxL[5].c[1] <== pathElements[5];
    muxL[5].s <== pathIndices[5];

    muxR[5] = Mux1();
    muxR[5].c[0] <== pathElements[5];
    muxR[5].c[1] <== intermediateHashes[5];
    muxR[5].s <== pathIndices[5];

    hashers[5] = Poseidon(2);
    hashers[5].inputs[0] <== muxL[5].out;
    hashers[5].inputs[1] <== muxR[5].out;
    intermediateHashes[6] <== hashers[5].out;

    // 第 6 层
    muxL[6] = Mux1();
    muxL[6].c[0] <== intermediateHashes[6];
    muxL[6].c[1] <== pathElements[6];
    muxL[6].s <== pathIndices[6];

    muxR[6] = Mux1();
    muxR[6].c[0] <== pathElements[6];
    muxR[6].c[1] <== intermediateHashes[6];
    muxR[6].s <== pathIndices[6];

    hashers[6] = Poseidon(2);
    hashers[6].inputs[0] <== muxL[6].out;
    hashers[6].inputs[1] <== muxR[6].out;
    intermediateHashes[7] <== hashers[6].out;

    // 第 7 层
    muxL[7] = Mux1();
    muxL[7].c[0] <== intermediateHashes[7];
    muxL[7].c[1] <== pathElements[7];
    muxL[7].s <== pathIndices[7];

    muxR[7] = Mux1();
    muxR[7].c[0] <== pathElements[7];
    muxR[7].c[1] <== intermediateHashes[7];
    muxR[7].s <== pathIndices[7];

    hashers[7] = Poseidon(2);
    hashers[7].inputs[0] <== muxL[7].out;
    hashers[7].inputs[1] <== muxR[7].out;
    intermediateHashes[8] <== hashers[7].out;

    // 第 8 层
    muxL[8] = Mux1();
    muxL[8].c[0] <== intermediateHashes[8];
    muxL[8].c[1] <== pathElements[8];
    muxL[8].s <== pathIndices[8];

    muxR[8] = Mux1();
    muxR[8].c[0] <== pathElements[8];
    muxR[8].c[1] <== intermediateHashes[8];
    muxR[8].s <== pathIndices[8];

    hashers[8] = Poseidon(2);
    hashers[8].inputs[0] <== muxL[8].out;
    hashers[8].inputs[1] <== muxR[8].out;
    intermediateHashes[9] <== hashers[8].out;

    // 第 9 层
    muxL[9] = Mux1();
    muxL[9].c[0] <== intermediateHashes[9];
    muxL[9].c[1] <== pathElements[9];
    muxL[9].s <== pathIndices[9];

    muxR[9] = Mux1();
    muxR[9].c[0] <== pathElements[9];
    muxR[9].c[1] <== intermediateHashes[9];
    muxR[9].s <== pathIndices[9];

    hashers[9] = Poseidon(2);
    hashers[9].inputs[0] <== muxL[9].out;
    hashers[9].inputs[1] <== muxR[9].out;
    intermediateHashes[10] <== hashers[9].out;

    // 第 10 层
    muxL[10] = Mux1();
    muxL[10].c[0] <== intermediateHashes[10];
    muxL[10].c[1] <== pathElements[10];
    muxL[10].s <== pathIndices[10];

    muxR[10] = Mux1();
    muxR[10].c[0] <== pathElements[10];
    muxR[10].c[1] <== intermediateHashes[10];
    muxR[10].s <== pathIndices[10];

    hashers[10] = Poseidon(2);
    hashers[10].inputs[0] <== muxL[10].out;
    hashers[10].inputs[1] <== muxR[10].out;
    intermediateHashes[11] <== hashers[10].out;

    // 第 11 层
    muxL[11] = Mux1();
    muxL[11].c[0] <== intermediateHashes[11];
    muxL[11].c[1] <== pathElements[11];
    muxL[11].s <== pathIndices[11];

    muxR[11] = Mux1();
    muxR[11].c[0] <== pathElements[11];
    muxR[11].c[1] <== intermediateHashes[11];
    muxR[11].s <== pathIndices[11];

    hashers[11] = Poseidon(2);
    hashers[11].inputs[0] <== muxL[11].out;
    hashers[11].inputs[1] <== muxR[11].out;
    intermediateHashes[12] <== hashers[11].out;

    // 第 12 层
    muxL[12] = Mux1();
    muxL[12].c[0] <== intermediateHashes[12];
    muxL[12].c[1] <== pathElements[12];
    muxL[12].s <== pathIndices[12];

    muxR[12] = Mux1();
    muxR[12].c[0] <== pathElements[12];
    muxR[12].c[1] <== intermediateHashes[12];
    muxR[12].s <== pathIndices[12];

    hashers[12] = Poseidon(2);
    hashers[12].inputs[0] <== muxL[12].out;
    hashers[12].inputs[1] <== muxR[12].out;
    intermediateHashes[13] <== hashers[12].out;

    // 第 13 层
    muxL[13] = Mux1();
    muxL[13].c[0] <== intermediateHashes[13];
    muxL[13].c[1] <== pathElements[13];
    muxL[13].s <== pathIndices[13];

    muxR[13] = Mux1();
    muxR[13].c[0] <== pathElements[13];
    muxR[13].c[1] <== intermediateHashes[13];
    muxR[13].s <== pathIndices[13];

    hashers[13] = Poseidon(2);
    hashers[13].inputs[0] <== muxL[13].out;
    hashers[13].inputs[1] <== muxR[13].out;
    intermediateHashes[14] <== hashers[13].out;

    // 第 14 层
    muxL[14] = Mux1();
    muxL[14].c[0] <== intermediateHashes[14];
    muxL[14].c[1] <== pathElements[14];
    muxL[14].s <== pathIndices[14];

    muxR[14] = Mux1();
    muxR[14].c[0] <== pathElements[14];
    muxR[14].c[1] <== intermediateHashes[14];
    muxR[14].s <== pathIndices[14];

    hashers[14] = Poseidon(2);
    hashers[14].inputs[0] <== muxL[14].out;
    hashers[14].inputs[1] <== muxR[14].out;
    intermediateHashes[15] <== hashers[14].out;

    // 第 15 层
    muxL[15] = Mux1();
    muxL[15].c[0] <== intermediateHashes[15];
    muxL[15].c[1] <== pathElements[15];
    muxL[15].s <== pathIndices[15];

    muxR[15] = Mux1();
    muxR[15].c[0] <== pathElements[15];
    muxR[15].c[1] <== intermediateHashes[15];
    muxR[15].s <== pathIndices[15];

    hashers[15] = Poseidon(2);
    hashers[15].inputs[0] <== muxL[15].out;
    hashers[15].inputs[1] <== muxR[15].out;
    intermediateHashes[16] <== hashers[15].out;

    // 第 16 层
    muxL[16] = Mux1();
    muxL[16].c[0] <== intermediateHashes[16];
    muxL[16].c[1] <== pathElements[16];
    muxL[16].s <== pathIndices[16];

    muxR[16] = Mux1();
    muxR[16].c[0] <== pathElements[16];
    muxR[16].c[1] <== intermediateHashes[16];
    muxR[16].s <== pathIndices[16];

    hashers[16] = Poseidon(2);
    hashers[16].inputs[0] <== muxL[16].out;
    hashers[16].inputs[1] <== muxR[16].out;
    intermediateHashes[17] <== hashers[16].out;

    // 第 17 层
    muxL[17] = Mux1();
    muxL[17].c[0] <== intermediateHashes[17];
    muxL[17].c[1] <== pathElements[17];
    muxL[17].s <== pathIndices[17];

    muxR[17] = Mux1();
    muxR[17].c[0] <== pathElements[17];
    muxR[17].c[1] <== intermediateHashes[17];
    muxR[17].s <== pathIndices[17];

    hashers[17] = Poseidon(2);
    hashers[17].inputs[0] <== muxL[17].out;
    hashers[17].inputs[1] <== muxR[17].out;
    intermediateHashes[18] <== hashers[17].out;

    // 第 18 层
    muxL[18] = Mux1();
    muxL[18].c[0] <== intermediateHashes[18];
    muxL[18].c[1] <== pathElements[18];
    muxL[18].s <== pathIndices[18];

    muxR[18] = Mux1();
    muxR[18].c[0] <== pathElements[18];
    muxR[18].c[1] <== intermediateHashes[18];
    muxR[18].s <== pathIndices[18];

    hashers[18] = Poseidon(2);
    hashers[18].inputs[0] <== muxL[18].out;
    hashers[18].inputs[1] <== muxR[18].out;
    intermediateHashes[19] <== hashers[18].out;

    // 第 19 层
    muxL[19] = Mux1();
    muxL[19].c[0] <== intermediateHashes[19];
    muxL[19].c[1] <== pathElements[19];
    muxL[19].s <== pathIndices[19];

    muxR[19] = Mux1();
    muxR[19].c[0] <== pathElements[19];
    muxR[19].c[1] <== intermediateHashes[19];
    muxR[19].s <== pathIndices[19];

    hashers[19] = Poseidon(2);
    hashers[19].inputs[0] <== muxL[19].out;
    hashers[19].inputs[1] <== muxR[19].out;
    intermediateHashes[20] <== hashers[19].out;

    root <== intermediateHashes[20];
}

// 余额证明模板
template BalanceProof() {
    // 公开输入
    signal input minBalance;      // 最小余额要求
    signal input merkleRoot;      // Merkle 树根
    signal input nullifierHash;   // nullifier 哈希（防双花）

    // 私有输入
    signal input balance;         // 用户余额
    signal input secret;          // 用户密钥
    signal input merklePath[20];
    signal input merkleIndex[20];

    // 输出
    signal output valid;

    // 1. 验证余额 >= minBalance
    component rangeCheck = GreaterEqThan(252);
    rangeCheck.in[0] <== balance;
    rangeCheck.in[1] <== minBalance;
    rangeCheck.out === 1;

    // 2. 计算 leaf = Poseidon(balance, secret)
    component leafHash = Poseidon(2);
    leafHash.inputs[0] <== balance;
    leafHash.inputs[1] <== secret;

    // 3. 验证 Merkle 证明
    component merkleProof = MerkleProof20();
    merkleProof.leaf <== leafHash.out;
    for (var i = 0; i < 20; i++) {
        merkleProof.pathElements[i] <== merklePath[i];
        merkleProof.pathIndices[i] <== merkleIndex[i];
    }

    // 4. 验证 Merkle 根
    merkleProof.root === merkleRoot;

    // 5. 计算 nullifier = Poseidon(secret, leafHash)
    // 使用两个 Poseidon 哈希来计算
    component nullifierHasher1 = Poseidon(2);
    nullifierHasher1.inputs[0] <== secret;
    nullifierHasher1.inputs[1] <== leafHash.out;

    component nullifierHasher2 = Poseidon(2);
    nullifierHasher2.inputs[0] <== nullifierHasher1.out;
    nullifierHasher2.inputs[1] <== 0;  // 填充

    nullifierHasher2.out === nullifierHash;

    // 6. 输出有效证明
    valid <== 1;
}

// 主电路
component main {public [minBalance, merkleRoot, nullifierHash]} = BalanceProof();
