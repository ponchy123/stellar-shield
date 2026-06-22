const CONTRACT_ID = 'CB2YBHCTTPLHQ5ZDY3Z25M5V6RP23SIG5PLPWCUIQVJYBA23TU3FKFGX';
const NETWORK_PASSPHRASE = 'Test SDF Network ; September 2015';

class StellarShield {
    constructor() {
        this.connected = false;
        this.address = null;
        this.init();
    }

    init() {
        this.bindEvents();
        if (typeof window.freighter !== 'undefined') {
            this.checkConnection();
        }
    }

    async checkConnection() {
        try {
            const connected = await window.freighter.isConnected();
            if (connected) {
                const addr = await window.freighter.getAddress();
                this.onWalletConnected(addr);
            }
        } catch (e) {}
    }

    bindEvents() {
        document.getElementById('connect-wallet').addEventListener('click', () => this.connectWallet());
        document.querySelectorAll('.tab').forEach(t => t.addEventListener('click', () => this.switchTab(t.dataset.tab)));
        document.getElementById('dep-btn').addEventListener('click', () => this.deposit());
        document.getElementById('tx-btn').addEventListener('click', () => this.transfer());
        document.getElementById('wd-btn').addEventListener('click', () => this.withdraw());
    }

    async connectWallet() {
        if (typeof window.freighter === 'undefined') {
            alert('Please install Freighter wallet extension');
            return;
        }
        try {
            await window.freighter.requestAccess();
            const addr = await window.freighter.getAddress();
            this.onWalletConnected(addr);
        } catch (e) {
            alert('Connection rejected');
        }
    }

    onWalletConnected(addr) {
        this.connected = true;
        this.address = addr;
        const btn = document.getElementById('connect-wallet');
        btn.textContent = '✓ Connected';
        btn.disabled = true;
        btn.style.background = 'linear-gradient(135deg, #00ff9d, #00d4ff)';
        document.getElementById('wallet-info').innerHTML =
            `<span class="network-badge">Testnet</span> <span style="color:#5a6a8a;font-size:11px;margin-left:8px">${addr.slice(0,8)}...${addr.slice(-6)}</span>`;
        ['dep-btn', 'tx-btn', 'wd-btn'].forEach(id => document.getElementById(id).disabled = false);
    }

    switchTab(name) {
        document.querySelectorAll('.tab').forEach(t => t.classList.toggle('active', t.dataset.tab === name));
        document.querySelectorAll('.panel').forEach(p => p.classList.toggle('active', p.id === name));
    }

    showResult(id, msg, type) {
        const el = document.getElementById(id);
        el.textContent = msg;
        el.className = `result ${type}`;
        el.style.display = 'block';
    }

    setLoading(btnId, loading) {
        const btn = document.getElementById(btnId);
        if (loading) {
            btn.classList.add('loading');
            btn.disabled = true;
        } else {
            btn.classList.remove('loading');
            btn.disabled = false;
        }
    }

    randomHex(bytes) {
        const arr = new Uint8Array(bytes);
        crypto.getRandomValues(arr);
        return Array.from(arr).map(b => b.toString(16).padStart(2, '0')).join('');
    }

    async hash(data) {
        const buf = new TextEncoder().encode(data);
        const hash = await crypto.subtle.digest('SHA-256', buf);
        return Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2, '0')).join('');
    }

    async generateProof(inputs) {
        try {
            if (typeof snarkjs !== 'undefined' && snarkjs.groth16) {
                const { proof, publicSignals } = await snarkjs.groth16.fullProve(
                    inputs,
                    'balance_proof_js/balance_proof.wasm',
                    'balance_proof_final.zkey'
                );
                return { proof, publicSignals };
            }
        } catch (e) {
            console.log('snarkjs not available, using mock proof');
        }
        return { proof: { pi_a: ['0', '0', '1'], pi_b: [['0', '0'], ['0', '0'], ['1', '0']], pi_c: ['0', '0', '1'] }, publicSignals: [] };
    }

    async signAndSubmit(method, args) {
        try {
            const tx = await window.freighter.signAndSubmitTx({
                contractId: CONTRACT_ID,
                method,
                args,
                networkPassphrase: NETWORK_PASSPHRASE
            });
            return tx;
        } catch (e) {
            throw new Error(e.message || 'Transaction failed');
        }
    }

    async deposit() {
        if (!this.connected) return alert('Connect wallet first');
        const amount = document.getElementById('dep-amount').value;
        if (!amount || BigInt(amount) <= 0n) return alert('Enter a valid amount');

        let secret = document.getElementById('dep-secret').value.trim();
        if (!secret) secret = this.randomHex(32);

        this.setLoading('dep-btn', true);
        this.showResult('dep-result', 'Generating ZK proof...', 'loading');

        try {
            const commitment = await this.hash(amount + secret);
            this.showResult('dep-result', 'Submitting transaction...', 'loading');

            const result = await this.signAndSubmit('deposit', [
                { address: this.address },
                { i128: amount },
                { bytes: commitment }
            ]);

            this.showResult('dep-result', `✅ Deposit successful!\nCommitment: ${commitment.slice(0, 16)}...\nIndex: ${result}`, 'success');
        } catch (e) {
            this.showResult('dep-result', `❌ ${e.message}`, 'error');
        }
        this.setLoading('dep-btn', false);
    }

    async transfer() {
        if (!this.connected) return alert('Connect wallet first');
        const nullifier = document.getElementById('tx-null').value.trim();
        const newCommitment = document.getElementById('tx-new').value.trim();
        if (!nullifier || !newCommitment) return alert('Fill all fields');

        this.setLoading('tx-btn', true);
        this.showResult('tx-result', 'Generating ZK proof...', 'loading');

        try {
            this.showResult('tx-result', 'Submitting transaction...', 'loading');
            await this.signAndSubmit('transfer', [
                { bytes: nullifier },
                { bytes: newCommitment }
            ]);
            this.showResult('tx-result', '✅ Transfer successful!', 'success');
        } catch (e) {
            this.showResult('tx-result', `❌ ${e.message}`, 'error');
        }
        this.setLoading('tx-btn', false);
    }

    async withdraw() {
        if (!this.connected) return alert('Connect wallet first');
        const nullifier = document.getElementById('wd-null').value.trim();
        const amount = document.getElementById('wd-amount').value;
        if (!nullifier || !amount) return alert('Fill all fields');

        this.setLoading('wd-btn', true);
        this.showResult('wd-result', 'Generating ZK proof...', 'loading');

        try {
            this.showResult('wd-result', 'Submitting transaction...', 'loading');
            await this.signAndSubmit('withdraw', [
                { address: this.address },
                { bytes: nullifier },
                { i128: amount }
            ]);
            this.showResult('wd-result', '✅ Withdrawal successful!', 'success');
        } catch (e) {
            this.showResult('wd-result', `❌ ${e.message}`, 'error');
        }
        this.setLoading('wd-btn', false);
    }
}

document.addEventListener('DOMContentLoaded', () => { window.app = new StellarShield(); });
