const CONTRACT_ID = 'CB2YBHCTTPLHQ5ZDY3Z25M5V6RP23SIG5PLPWCUIQVJYBA23TU3FKFGX';
const RPC_URL = 'https://soroban-testnet.stellar.org';
const NETWORK_PASSPHRASE = 'Test SDF Network ; September 2015';

class StellarShield {
    constructor() {
        this.connected = false;
        this.walletAddress = null;
        this.init();
    }

    init() {
        this.bindEvents();
        this.checkFreighter();
    }

    checkFreighter() {
        if (typeof window.freighter !== 'undefined') {
            console.log('Freighter detected');
        } else {
            this.showStatus('deposit', 'Please install Freighter wallet extension', 'error');
        }
    }

    bindEvents() {
        document.getElementById('connect-wallet').addEventListener('click', () => this.connectWallet());
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', () => this.switchTab(tab.dataset.tab));
        });
        document.getElementById('deposit-btn').addEventListener('click', () => this.deposit());
        document.getElementById('transfer-btn').addEventListener('click', () => this.transfer());
        document.getElementById('withdraw-btn').addEventListener('click', () => this.withdraw());
    }

    async connectWallet() {
        try {
            if (typeof window.freighter === 'undefined') {
                alert('Please install Freighter wallet');
                return;
            }
            const address = await window.freighter.getAddress();
            this.walletAddress = address;
            this.connected = true;
            document.getElementById('connect-wallet').textContent = 'Connected';
            document.getElementById('connect-wallet').disabled = true;
            document.getElementById('wallet-address').textContent = address;
            document.getElementById('deposit-btn').disabled = false;
            document.getElementById('transfer-btn').disabled = false;
            document.getElementById('withdraw-btn').disabled = false;
        } catch (e) {
            alert('Failed to connect: ' + e.message);
        }
    }

    switchTab(tabName) {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
        document.getElementById(tabName).classList.add('active');
    }

    showStatus(tab, msg, type) {
        const el = document.getElementById(`${tab}-status`);
        el.textContent = type === 'loading' ? `⏳ ${msg}` : (type === 'success' ? `✅ ${msg}` : `❌ ${msg}`);
        el.className = `status ${type}`;
        el.style.display = 'block';
    }

    hideStatus(tab) {
        document.getElementById(`${tab}-status`).style.display = 'none';
    }

    async invokeContract(fn, args = {}) {
        const fnArgs = [];
        for (const [key, val] of Object.entries(args)) {
            fnArgs.push(`--${key.replace(/_/g, '-')}`, String(val));
        }

        const response = await fetch(RPC_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                jsonrpc: '2.0',
                id: 1,
                method: 'simulateTransaction',
                params: {
                    transaction: await this.buildTx(fn, args)
                }
            })
        });
        return response.json();
    }

    async buildTx(fn, args) {
        const txParams = {
            source: this.walletAddress,
            networkPassphrase: NETWORK_PASSPHRASE,
            contractId: CONTRACT_ID,
            method: fn,
            args: this.buildArgs(fn, args),
            instructionParameter: { readOnly: false }
        };
        return await window.freighter.signTransaction(
            await this.createTransaction(txParams),
            { network: NETWORK_PASSPHRASE }
        );
    }

    buildArgs(fn, args) {
        const result = [];
        switch (fn) {
            case 'deposit':
                result.push(
                    { address: args.sender },
                    { i128: args.amount },
                    { bytes: args.commitment }
                );
                break;
            case 'transfer':
                result.push(
                    { bytes: args.nullifier_hash },
                    { bytes: args.new_commitment }
                );
                break;
            case 'withdraw':
                result.push(
                    { address: args.to },
                    { bytes: args.nullifier_hash },
                    { i128: args.amount }
                );
                break;
        }
        return result;
    }

    async deposit() {
        if (!this.connected) { alert('Connect wallet first'); return; }
        const amount = document.getElementById('deposit-amount').value;
        if (!amount || parseInt(amount) <= 0) { alert('Enter valid amount'); return; }

        let secret = document.getElementById('deposit-secret').value;
        if (!secret) secret = this.randomHex(32);

        const commitment = await this.poseidonHash([amount, secret]);
        this.showStatus('deposit', 'Generating proof & submitting...', 'loading');

        try {
            const result = await window.freighter.signAndSubmitTx({
                contractId: CONTRACT_ID,
                method: 'deposit',
                args: [
                    { address: this.walletAddress },
                    { i128: amount },
                    { bytes: commitment }
                ],
                networkPassphrase: NETWORK_PASSPHRASE
            });
            this.showStatus('deposit', `Deposited! Index: ${result}`, 'success');
        } catch (e) {
            this.showStatus('deposit', e.message || 'Transaction failed', 'error');
        }
    }

    async transfer() {
        if (!this.connected) { alert('Connect wallet first'); return; }
        const nullifier = document.getElementById('transfer-nullifier').value;
        const newCommitment = document.getElementById('transfer-new-commitment').value;
        if (!nullifier || !newCommitment) { alert('Fill all fields'); return; }

        this.showStatus('transfer', 'Submitting transfer...', 'loading');
        try {
            await window.freighter.signAndSubmitTx({
                contractId: CONTRACT_ID,
                method: 'transfer',
                args: [
                    { bytes: nullifier },
                    { bytes: newCommitment }
                ],
                networkPassphrase: NETWORK_PASSPHRASE
            });
            this.showStatus('transfer', 'Transfer successful!', 'success');
        } catch (e) {
            this.showStatus('transfer', e.message || 'Transaction failed', 'error');
        }
    }

    async withdraw() {
        if (!this.connected) { alert('Connect wallet first'); return; }
        const nullifier = document.getElementById('withdraw-nullifier').value;
        const amount = document.getElementById('withdraw-amount').value;
        if (!nullifier || !amount) { alert('Fill all fields'); return; }

        this.showStatus('withdraw', 'Submitting withdrawal...', 'loading');
        try {
            await window.freighter.signAndSubmitTx({
                contractId: CONTRACT_ID,
                method: 'withdraw',
                args: [
                    { address: this.walletAddress },
                    { bytes: nullifier },
                    { i128: amount }
                ],
                networkPassphrase: NETWORK_PASSPHRASE
            });
            this.showStatus('withdraw', 'Withdrawal successful!', 'success');
        } catch (e) {
            this.showStatus('withdraw', e.message || 'Transaction failed', 'error');
        }
    }

    randomHex(bytes) {
        const arr = new Uint8Array(bytes);
        crypto.getRandomValues(arr);
        return Array.from(arr).map(b => b.toString(16).padStart(2, '0')).join('');
    }

    async poseidonHash(inputs) {
        const arr = new TextEncoder().encode(inputs.join(','));
        const hash = await crypto.subtle.digest('SHA-256', arr);
        return Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2, '0')).join('');
    }
}

document.addEventListener('DOMContentLoaded', () => { window.app = new StellarShield(); });
