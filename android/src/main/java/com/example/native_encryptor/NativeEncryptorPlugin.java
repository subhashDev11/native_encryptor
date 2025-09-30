package com.example.native_encryptor;

import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import java.util.HashMap;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * NativeEncryptorPlugin
 */
public class NativeEncryptorPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    AESEncryptionService aesEncryptionService = new AESEncryptionService();

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "native_encryptor");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("encrypt")) {
            try {
                HashMap<String, String> data = (HashMap<String, String>) call.arguments;
                PlugInUtility.logInfo("Received params - " + data.toString());
                String encryptedValue = onEncryptMethodCall(Objects.requireNonNull(data.get("passPhrase")), Objects.requireNonNull(data.get("contentToEncrypt")));
                PlugInUtility.logInfo("Encrypted data - " + encryptedValue);
                result.success(encryptedValue);
            } catch (Exception e) {
                PlugInUtility.logError("Error on encryption - " + e.getMessage(), e.fillInStackTrace());
                result.error("", e.getMessage(), e.getLocalizedMessage());
            }
        } else if (call.method.equals("decrypt")) {
            try {
                HashMap<String, String> data = (HashMap<String, String>) call.arguments;
                PlugInUtility.logInfo("Received params - " + data.toString());
                String decryptedValue = onDecryptMethodCall(Objects.requireNonNull(data.get("passPhrase")), Objects.requireNonNull(data.get("concatenatedCipherText")));
                PlugInUtility.logInfo("Decrypted data - " + decryptedValue);
                result.success(decryptedValue);
            } catch (Exception e) {
                PlugInUtility.logError("Error on decryption - " + e.getMessage(), e.fillInStackTrace());
                result.error("", e.getMessage(), e.getLocalizedMessage());
            }
        }

        /// encrypt/decrypt with custom IV
        else if (call.method.equals("encrypt_with_custom_iv")) {
            try {
                PlugInUtility.logInfo("encrypt_with_custom_iv in action....");
                HashMap<String, String> data = (HashMap<String, String>) call.arguments;
                PlugInUtility.logInfo("Received params - " + data.toString());
                String encryptedValue = onEncryptWithIVMethodCall(Objects.requireNonNull(data.get("passPhrase")), Objects.requireNonNull(data.get("iv")), Objects.requireNonNull(data.get("contentToEncrypt")));
                PlugInUtility.logInfo("Encrypted data - " + encryptedValue);
                result.success(encryptedValue);
            } catch (Exception e) {
                PlugInUtility.logError("Error on encryption - " + e.getMessage(), e.fillInStackTrace());
                result.error("", e.getMessage(), e.getLocalizedMessage());
            }
        } else if (call.method.equals("decrypt_with_custom_iv")) {
            try {
                PlugInUtility.logInfo("decrypt_with_custom_iv in action....");
                HashMap<String, String> data = (HashMap<String, String>) call.arguments;
                PlugInUtility.logInfo("Received params - " + data.toString());
                String decryptedValue = onDecryptWithIVMethodCall(Objects.requireNonNull(data.get("passPhrase")), Objects.requireNonNull(data.get("iv")), Objects.requireNonNull(data.get("concatenatedCipherText")));
                PlugInUtility.logInfo("Decrypted data - " + decryptedValue);
                result.success(decryptedValue);
            } catch (Exception e) {
                PlugInUtility.logError("Error on decryption - " + e.getMessage(), e.fillInStackTrace());
                result.error("", e.getMessage(), e.getLocalizedMessage());
            }
        } else {
            result.notImplemented();
        }
    }

    String onEncryptMethodCall(@NonNull String passPhrase, @NonNull String content) {
        return aesEncryptionService.encrypt(passPhrase, content);
    }

    String onDecryptMethodCall(@NonNull String passPhrase, @NonNull String encryptedValue) {
        return aesEncryptionService.decrypt(passPhrase, encryptedValue);
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    String onEncryptWithIVMethodCall(@NonNull String passPhrase, @NonNull String iv, @NonNull String content) {
        return CustomIVEDService.getEncryptedString(passPhrase, iv, content);
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    String onDecryptWithIVMethodCall(@NonNull String passPhrase, @NonNull String iv, @NonNull String encryptedValue) {
        return CustomIVEDService.getDecryptedString(passPhrase, iv, encryptedValue);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
