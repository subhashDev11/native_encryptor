class AESEncryptionService {
    constructor(keySize = 256, iterationCount = 1989) {
        this.keySize = keySize;
        this.iterationCount = iterationCount;
        this.ivSize = 128;
    }

    toBase64(arrayBuffer) {
        return btoa(String.fromCharCode(...new Uint8Array(arrayBuffer)));
    }

    fromBase64(base64) {
        let binary_string = atob(base64);
        let len = binary_string.length;
        let bytes = new Uint8Array(len);
        for (let i = 0; i < len; i++) {
            bytes[i] = binary_string.charCodeAt(i);
        }
        return bytes.buffer;
    }

    toHex(arrayBuffer) {
        return Array.from(new Uint8Array(arrayBuffer)).map(byte => byte.toString(16).padStart(2, '0')).join('');
    }

    fromHex(hex) {
        let bytes = new Uint8Array(hex.length / 2);
        for (let i = 0; i < hex.length; i += 2) {
            bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
        }
        return bytes.buffer;
    }

    async generateKey(salt, passPhrase) {
        const encoder = new TextEncoder();
        const passphraseBytes = encoder.encode(passPhrase);
        const saltBytes = this.fromHex(salt);

        const keyMaterial = await crypto.subtle.importKey(
            "raw", passphraseBytes, { name: "PBKDF2" }, false, ["deriveKey"]
        );

        return crypto.subtle.deriveKey(
            { name: "PBKDF2", salt: saltBytes, iterations: this.iterationCount, hash: "SHA-256" },
            keyMaterial, { name: "AES-CBC", length: this.keySize },
            false, ["encrypt", "decrypt"]
        );
    }

    async encrypt(salt, iv, passPhrase, plainText) {
        const key = await this.generateKey(salt, passPhrase);
        const encoder = new TextEncoder();
        const data = encoder.encode(plainText);
        const ivBytes = this.fromHex(iv);

        const encryptedData = await crypto.subtle.encrypt(
            { name: "AES-CBC", iv: ivBytes },
            key, data
        );

        return this.toBase64(encryptedData);
    }

    async decrypt(salt, iv, passPhrase, cipherText) {
        const key = await this.generateKey(salt, passPhrase);
        const ivBytes = this.fromHex(iv);
        const encryptedData = this.fromBase64(cipherText);

        const decryptedData = await crypto.subtle.decrypt(
            { name: "AES-CBC", iv: ivBytes },
            key, encryptedData
        );

        const decoder = new TextDecoder();
        return decoder.decode(decryptedData);
    }

    async encryptWithRandomSaltAndIv(passPhrase, plainText) {
        const salt = this.toHex(this.generateRandom(this.keySize / 8));
        const iv = this.toHex(this.generateRandom(this.ivSize / 8));
        const cipherText = await this.encrypt(salt, iv, passPhrase, plainText);

        return salt + iv + cipherText;
    }

    async decryptWithConcatenatedCipherText(passPhrase, concatenatedCipherText) {
        const salt = concatenatedCipherText.substring(0, this.keySize / 4); // Extract salt
        const iv = concatenatedCipherText.substring(this.keySize / 4, (this.keySize / 4) + (this.ivSize / 4)); // Extract IV
        const cipherText = concatenatedCipherText.substring((this.keySize / 4) + (this.ivSize / 4)); // Extract cipherText

        return await this.decrypt(salt, iv, passPhrase, cipherText);
    }

    generateRandom(length) {
        const randomBytes = new Uint8Array(length);
        crypto.getRandomValues(randomBytes);
        return randomBytes;
    }
}

window.aesService = new AESEncryptionService();