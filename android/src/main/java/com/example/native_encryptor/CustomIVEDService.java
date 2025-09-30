package com.example.native_encryptor;

import android.os.Build;

import androidx.annotation.RequiresApi;

import java.nio.charset.StandardCharsets;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class CustomIVEDService {
    @RequiresApi(api = Build.VERSION_CODES.O)
    public static String getEncryptedString(String secKey, String secIv, String data) {
        Cipher ciper;
        byte[] encryptedCiperBytes = null;
        try {
            ciper = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec key = new SecretKeySpec(secKey.getBytes(StandardCharsets.UTF_8), "AES");
            IvParameterSpec iv = new IvParameterSpec(secIv.getBytes(StandardCharsets.UTF_8), 0, ciper.getBlockSize());
            // Encrypt
            ciper.init(Cipher.ENCRYPT_MODE, key, iv);
            encryptedCiperBytes = ciper.doFinal(data.getBytes());

        } catch (Exception e) {
            PlugInUtility.logError(e.getMessage(), e.fillInStackTrace());
            return "INVALID_KEY";
        }
        return Base64.getEncoder().encodeToString(encryptedCiperBytes);
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    public static String getDecryptedString(String secKey, String secIv, String data) {
        Cipher ciper;
        byte[] text = null;
        try {
            ciper = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec key = new SecretKeySpec(secKey.getBytes(StandardCharsets.UTF_8), "AES");
            IvParameterSpec iv = new IvParameterSpec(secIv.getBytes(StandardCharsets.UTF_8), 0, ciper.getBlockSize());
            ciper.init(Cipher.DECRYPT_MODE, key, iv);
            text = ciper.doFinal(Base64.getDecoder().decode(data));
        } catch (Exception e) {
            PlugInUtility.logError(e.getMessage(), e.fillInStackTrace());
            return "INVALID_KEY";
        }
        return new String(text);
    }

}
