//
//  CustomIVEDService.swift
//  Pods
//
//  Created by Subhash Chandra Shukla on 30/09/25.
//


//
//  CustomIVEDService.swift
//  native_encryptor
//
//  Created by Subhash Chandra Shukla
//

import Foundation
import CommonCrypto

class CustomIVEDService {
    private static let blockSize = kCCBlockSizeAES128
    private static let keySize = kCCKeySizeAES256

    static func encrypt(passPhrase: String, iv: String, plainText: String) -> String? {
        guard let keyData = passPhrase.data(using: .utf8),
              let ivData = iv.data(using: .utf8),
              let plainData = plainText.data(using: .utf8) else {
            return nil
        }

        let cryptLength = size_t(plainData.count + blockSize)
        var cryptData = Data(count: cryptLength)

        var numBytesEncrypted: size_t = 0

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            plainData.withUnsafeBytes { dataBytes in
                ivData.withUnsafeBytes { ivBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            keySize,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress,
                            plainData.count,
                            cryptBytes.baseAddress,
                            cryptLength,
                            &numBytesEncrypted
                        )
                    }
                }
            }
        }

        guard status == kCCSuccess else { return nil }
        cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
        return cryptData.base64EncodedString()
    }

    static func decrypt(passPhrase: String, iv: String, cipherText: String) -> String? {
        guard let keyData = passPhrase.data(using: .utf8),
              let ivData = iv.data(using: .utf8),
              let cipherData = Data(base64Encoded: cipherText) else {
            return nil
        }

        let cryptLength = size_t(cipherData.count + blockSize)
        var cryptData = Data(count: cryptLength)

        var numBytesDecrypted: size_t = 0

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            cipherData.withUnsafeBytes { dataBytes in
                ivData.withUnsafeBytes { ivBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            keySize,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress,
                            cipherData.count,
                            cryptBytes.baseAddress,
                            cryptLength,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }

        guard status == kCCSuccess else { return nil }
        cryptData.removeSubrange(numBytesDecrypted..<cryptData.count)
        return String(data: cryptData, encoding: .utf8)
    }
}
