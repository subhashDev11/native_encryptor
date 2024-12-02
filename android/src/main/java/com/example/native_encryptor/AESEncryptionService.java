package com.example.native_encryptor;

import static android.util.Base64.*;

import java.nio.charset.StandardCharsets;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
//import java.util.Base64;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import android.util.Base64;

public class AESEncryptionService {

    public enum DataType {
        HEX,
        BASE64
    }

    private static final String CIPHER_ALGORITHM = "AES/CBC/PKCS5Padding";
    private static final String SECRET_KEY_ALGORITHM = "PBKDF2WithHmacSHA1";
    private static final String KEY_ALGORITHM = "AES";

    private static final int IV_SIZE = 128;

    private int iterationCount = 1989;
    private int keySize = 256;
    private int saltLength;

    private final DataType dataType = DataType.BASE64;

    private Cipher cipher;

    public AESEncryptionService() {
        try {
            cipher = Cipher.getInstance(CIPHER_ALGORITHM);
            setSaltLength(this.keySize / 4);
        } catch (NoSuchPaddingException | NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
    }

    public AESEncryptionService(int keySize, int iterationCount) {
        this.keySize = keySize;
        this.iterationCount = iterationCount;
        try {
            cipher = Cipher.getInstance(CIPHER_ALGORITHM);
            setSaltLength(this.keySize / 4);
        } catch (NoSuchPaddingException | NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
    }

    public String encrypt(String salt, String iv, String passPhrase, String plainText) {
        try {
            SecretKey secretKey = generateKey(salt, passPhrase);
            byte[] encrypted = doFinal(Cipher.ENCRYPT_MODE, secretKey, iv, plainText.getBytes(StandardCharsets.UTF_8));
            return dataType.equals(DataType.HEX) ? toHex(encrypted) : toBase64(encrypted);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public String encrypt(String passPhrase, String plainText) {
        try {
            String salt = toHex(generateRandom(keySize / 8));
            String iv = toHex(generateRandom(IV_SIZE / 8));
            String cipherText = encrypt(salt, iv, passPhrase, plainText);
            return salt + iv + cipherText;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public String decrypt(String salt, String iv, String passPhrase, String cipherText) {
        try {
            SecretKey secretKey = generateKey(salt, passPhrase);
            byte[] encryptedBytes = dataType.equals(DataType.HEX) ? fromHex(cipherText) : fromBase64(cipherText);
            byte[] decrypted = doFinal(Cipher.DECRYPT_MODE, secretKey, iv, encryptedBytes);
            return new String(decrypted, StandardCharsets.UTF_8);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public String decrypt(String passPhrase, String concatenatedCipherText) {
        try {
            String salt = concatenatedCipherText.substring(0, keySize / 4); // Extract salt
            String iv = concatenatedCipherText.substring(keySize / 4, (keySize / 4) + (IV_SIZE / 4)); // Extract IV
            String cipherText = concatenatedCipherText.substring((keySize / 4) + (IV_SIZE / 4)); // Extract cipherText
            return decrypt(salt, iv, passPhrase, cipherText);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private SecretKey generateKey(String salt, String passPhrase) {
        try {
            SecretKeyFactory secretKeyFactory = SecretKeyFactory.getInstance(SECRET_KEY_ALGORITHM);
            KeySpec keySpec = new PBEKeySpec(passPhrase.toCharArray(), fromHex(salt), iterationCount, keySize);
            return new SecretKeySpec(secretKeyFactory.generateSecret(keySpec).getEncoded(), KEY_ALGORITHM);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            e.printStackTrace();
            return null;
        }
    }

    private static String toBase64(byte[] ba) {
        return Base64.encodeToString(ba, DEFAULT);
    }

    private static byte[] fromBase64(String str) {
        return Base64.decode(str, DEFAULT);
    }

    private static String toHex(byte[] ba) {
        StringBuilder hex = new StringBuilder(ba.length * 2);
        for (byte b : ba) {
            hex.append(String.format("%02x", b));
        }
        return hex.toString();
    }

    private static byte[] fromHex(String str) {
        int len = str.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(str.charAt(i), 16) << 4)
                    + Character.digit(str.charAt(i + 1), 16));
        }
        return data;
    }

    private byte[] doFinal(int mode, SecretKey secretKey, String iv, byte[] bytes) {
        try {
            cipher.init(mode, secretKey, new IvParameterSpec(fromHex(iv)));
            return cipher.doFinal(bytes);
        } catch (InvalidAlgorithmParameterException | IllegalBlockSizeException | BadPaddingException | InvalidKeyException e) {
            e.printStackTrace();
            return null;
        }
    }

    private static byte[] generateRandom(int length) {
        SecureRandom random = new SecureRandom();
        byte[] randomBytes = new byte[length];
        random.nextBytes(randomBytes);
        return randomBytes;
    }

    public int getSaltLength() {
        return saltLength;
    }

    public void setSaltLength(int saltLength) {
        this.saltLength = saltLength;
    }
}