//
//  AESEncryptionService.swift
//  native_encryptor
//
//  Created by Subhash Chandra Shukla on 30/11/24.
//

import Foundation
import CommonCrypto

class AESEncryptionService {
    enum DataType {
        case hex
        case base64
    }

    private let cipherAlgorithm = CCAlgorithm(kCCAlgorithmAES)
    private let blockSize = kCCBlockSizeAES128
    private let keySize: Int
    private let iterationCount: Int
    private let dataType: DataType
    private var saltLength: Int

    init(keySize: Int = 256, iterationCount: Int = 1989, dataType: DataType = .base64) {
        self.keySize = keySize / 8
        self.iterationCount = iterationCount
        self.dataType = dataType
        self.saltLength = keySize / 4
    }

    func encrypt(salt: String, iv: String, passphrase: String, plainText: String) -> String? {
        guard let secretKey = generateKey(salt: salt, passphrase: passphrase),
              let ivData = fromHex(iv),
              let plainData = plainText.data(using: .utf8) else {
            return nil
        }

        return performEncryptionOrDecryption(
            operation: CCOperation(kCCEncrypt),
            key: secretKey,
            iv: ivData,
            input: plainData
        )
    }

    func encrypt(passphrase: String, plainText: String) -> String? {
        let salt = toHex(generateRandomBytes(length: keySize))
        let iv = toHex(generateRandomBytes(length: blockSize))
        guard let cipherText = encrypt(salt: salt, iv: iv, passphrase: passphrase, plainText: plainText) else {
            return nil
        }

        return salt + iv + cipherText
    }

    func decrypt(salt: String, iv: String, passphrase: String, cipherText: String) -> String? {
        guard let secretKey = generateKey(salt: salt, passphrase: passphrase),
              let ivData = fromHex(iv),
              let cipherData = dataType == .hex ? fromHex(cipherText) : Data(base64Encoded: cipherText) else {
            return nil
        }

        return performEncryptionOrDecryption(
            operation: CCOperation(kCCDecrypt),
            key: secretKey,
            iv: ivData,
            input: cipherData
        )
    }

    func decrypt(passphrase: String, concatenatedCipherText: String) -> String? {
        let saltEndIndex = keySize * 2
        let ivStartIndex = concatenatedCipherText.index(concatenatedCipherText.startIndex, offsetBy: saltEndIndex)
        let ivEndIndex = concatenatedCipherText.index(ivStartIndex, offsetBy: blockSize * 2)
        let cipherTextStartIndex = ivEndIndex

        let salt = String(concatenatedCipherText[..<ivStartIndex])
        let iv = String(concatenatedCipherText[ivStartIndex..<ivEndIndex])
        let cipherText = String(concatenatedCipherText[cipherTextStartIndex...])

        return decrypt(salt: salt, iv: iv, passphrase: passphrase, cipherText: cipherText)
    }

    private func generateKey(salt: String, passphrase: String) -> Data? {
        guard let saltData = fromHex(salt),
              let passphraseData = passphrase.data(using: .utf8) else {
            return nil
        }

        var key = Data(count: keySize)
        let result = key.withUnsafeMutableBytes { keyBytes in
            saltData.withUnsafeBytes { saltBytes in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    passphrase,
                    passphrase.count,
                    saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    saltBytes.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
                    UInt32(iterationCount),
                    keyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    keySize
                )
            }
        }

        return result == kCCSuccess ? key : nil
    }

    private func performEncryptionOrDecryption(
        operation: CCOperation,
        key: Data,
        iv: Data,
        input: Data
    ) -> String? {
        // Allocate enough space for the output buffer
        var output = Data(count: input.count + blockSize)
        var outputLength = 0

        // Calculate the expected size of the output data
        let outputSize = output.count

        let result = output.withUnsafeMutableBytes { outputBytes in
            key.withUnsafeBytes { keyBytes in
                iv.withUnsafeBytes { ivBytes in
                    input.withUnsafeBytes { inputBytes in
                        CCCrypt(
                            operation,
                            cipherAlgorithm,
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            keySize,
                            ivBytes.baseAddress,
                            inputBytes.baseAddress,
                            input.count,
                            outputBytes.baseAddress,
                            outputSize,
                            &outputLength
                        )
                    }
                }
            }
        }

        guard result == kCCSuccess else { return nil }

        // Trim the output to the correct length after the operation
        output.removeSubrange(outputLength..<output.count)
        return dataType == .hex ? toHex(output) : output.base64EncodedString()
    }

    private func generateRandomBytes(length: Int) -> Data {
        var data = Data(count: length)
        _ = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        return data
    }

    private func toHex(_ data: Data) -> String {
        return data.map { String(format: "%02x", $0) }.joined()
    }

    private func fromHex(_ hex: String) -> Data? {
        var data = Data()
        var tempHex = hex
        while tempHex.count >= 2 {
            let byteString = String(tempHex.prefix(2))
            tempHex.removeFirst(2)
            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            } else {
                return nil
            }
        }
        return data
    }
}
