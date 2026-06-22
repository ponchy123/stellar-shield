# StellarShield 演示视频脚本

## 视频时长：2-3 分钟

---

### 场景 1：开场 (0:00 - 0:15)

**画面**：StellarShield Logo 动画 + 标题

**旁白**：
"StellarShield - A Zero-Knowledge Privacy Protocol on Stellar. Today I'll show you how we enable private transactions using ZK proofs."

**字幕**：
- StellarShield
- Zero-Knowledge Privacy on Stellar

---

### 场景 2：问题介绍 (0:15 - 0:30)

**画面**：展示区块链浏览器上的公开交易

**旁白**：
"Today, all Stellar transactions are public. Anyone can see who sent what to whom. This is a privacy problem for real-world use cases like payroll, donations, or business payments."

**字幕**：
- Problem: All transactions are public
- Solution: Zero-knowledge proofs

---

### 场景 3：连接钱包 (0:30 - 0:45)

**画面**：打开前端界面，点击 "Connect Freighter"

**旁白**：
"Let's start by connecting our Freighter wallet."

**操作**：
1. 打开 http://localhost:8000
2. 点击 "Connect Freighter" 按钮
3. Freighter 弹窗确认连接
4. 显示已连接地址

**字幕**：
- Connected: GC6EU5...MMQGU

---

### 场景 4：存款 (0:45 - 1:15)

**画面**：Deposit 标签页

**旁白**：
"Now let's deposit some tokens. I'll enter the amount and click Deposit."

**操作**：
1. 输入金额：1000000000
2. 点击 "Deposit" 按钮
3. 等待交易确认
4. 显示成功消息

**旁白**：
"The deposit is recorded on-chain, but the amount is hidden behind a cryptographic commitment."

**字幕**：
- Commitment: H(amount, secret)
- Amount is private

---

### 场景 5：链上验证 (1:15 - 1:30)

**画面**：打开 Stellar Expert 查看交易

**旁白**：
"Let's verify on the blockchain explorer. You can see the transaction, but the actual amount is not visible."

**操作**：
1. 打开 Stellar Expert
2. 搜索合约地址
3. 展示交易详情
4. 指出 commitment 哈希

**字幕**：
- Transaction visible
- Amount hidden

---

### 场景 6：转账 (1:30 - 2:00)

**画面**：Transfer 标签页

**旁白**：
"Now let's do a private transfer. We spend an existing commitment and create a new one."

**操作**：
1. 输入 commitment 索引
2. 输入 nullifier（防双花）
3. 输入新的 commitment
4. 点击 "Transfer"

**旁白**：
"The nullifier prevents double-spending, while the new commitment hides the recipient."

**字幕**：
- Nullifier: Prevents double-spend
- New commitment: Hides recipient

---

### 场景 7：取款 (2:00 - 2:20)

**画面**：Withdraw 标签页

**旁白**：
"Finally, let's withdraw. The user proves knowledge of a commitment without revealing which one."

**操作**：
1. 输入 commitment 索引
2. 输入 nullifier
3. 输入金额
4. 点击 "Withdraw"

**字幕**：
- Proof of knowledge
- No identity revealed

---

### 场景 8：技术亮点 (2:20 - 2:40)

**画面**：架构图 + 代码片段

**旁白**：
"StellarShield uses Groth16 proofs generated client-side with snarkjs. The ZK circuit verifies balance proofs, Merkle paths, and nullifiers - all without revealing private data."

**字幕**：
- Groth16 proofs (Groth16)
- Client-side generation
- 5,882 constraints

---

### 场景 9：总结 (2:40 - 3:00)

**画面**：项目特性列表

**旁白**：
"StellarShield brings privacy to Stellar transactions using zero-knowledge proofs. Built on Soroban with a clean, user-friendly interface."

**字幕**：
- Zero-knowledge privacy
- Stellar native (Soroban)
- Open source

**结束画面**：
- GitHub: [link]
- Testnet: CB2YBHCTTPLHQ5ZDY3Z25M5V6RP23SIG5PLPWCUIQVJYBA23TU3FKFGX
- Made with ❤️ for Stellar Hacks

---

## 录制清单

- [ ] 安装 Freighter 钱包
- [ ] 创建 Testnet 账户并充值
- [ ] 启动前端服务器
- [ ] 准备 Stellar Expert 页面
- [ ] 录制屏幕
- [ ] 录制旁白
- [ ] 剪辑合成

## 工具推荐

- **屏幕录制**: OBS Studio
- **视频剪辑**: DaVinci Resolve (免费)
- **字幕**: 使用剪辑软件内置功能
