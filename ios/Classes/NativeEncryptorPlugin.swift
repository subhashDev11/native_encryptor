import Flutter
import UIKit

public class NativeEncryptorPlugin: NSObject, FlutterPlugin {
    private let aesEncryptionService = AESEncryptionService()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_encryptor", binaryMessenger: registrar.messenger())
        let instance = NativeEncryptorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "encrypt":
            handleEncrypt(call: call, result: result)
        case "decrypt":
            handleDecrypt(call: call, result: result)
        case "encrypt_with_custom_iv":
            handleEncryptWithCustomIV(call: call, result: result)
        case "decrypt_with_custom_iv":
            handleDecryptWithCustomIV(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleEncrypt(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            let args = call.arguments as? [String: String],
            let passPhrase = args["passPhrase"],
            let contentToEncrypt = args["contentToEncrypt"]
        else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing encryption arguments", details: nil))
            return
        }

        do {
            let encryptedValue = try aesEncryptionService.encrypt(passphrase: passPhrase, plainText: contentToEncrypt)
            result(encryptedValue)
        } catch let error {
            result(FlutterError(code: "ENCRYPTION_ERROR", message: error.localizedDescription, details: nil))
        }
    }

    private func handleDecrypt(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            let args = call.arguments as? [String: String],
            let passPhrase = args["passPhrase"],
            let concatenatedCipherText = args["concatenatedCipherText"]
        else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing decryption arguments", details: nil))
            return
        }

        do {
            let decryptedValue = try aesEncryptionService.decrypt(
                passphrase: passPhrase,
                concatenatedCipherText: concatenatedCipherText
            )
            result(decryptedValue)
        } catch let error {
            result(FlutterError(code: "DECRYPTION_ERROR", message: error.localizedDescription, details: nil))
        }
    }

    private func handleEncryptWithCustomIV(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            let args = call.arguments as? [String: String],
            let passPhrase = args["passPhrase"],
            let iv = args["iv"],
            let contentToEncrypt = args["contentToEncrypt"]
        else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing custom IV encryption arguments", details: nil))
            return
        }

        if let encryptedValue = CustomIVEDService.encrypt(passPhrase: passPhrase, iv: iv, plainText: contentToEncrypt) {
            result(encryptedValue)
        } else {
            result(FlutterError(code: "ENCRYPTION_ERROR", message: "Custom IV encryption failed", details: nil))
        }
    }

    private func handleDecryptWithCustomIV(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            let args = call.arguments as? [String: String],
            let passPhrase = args["passPhrase"],
            let iv = args["iv"],
            let concatenatedCipherText = args["concatenatedCipherText"]
        else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing custom IV decryption arguments", details: nil))
            return
        }

        if let decryptedValue = CustomIVEDService.decrypt(passPhrase: passPhrase, iv: iv, cipherText: concatenatedCipherText) {
            result(decryptedValue)
        } else {
            result(FlutterError(code: "DECRYPTION_ERROR", message: "Custom IV decryption failed", details: nil))
        }
    }
}
