// PBKDF2.swift

import Foundation
import CommonCrypto

public struct PBKDF2 {
    public static func SHA512(password: Data, salt: Data, c: UInt32 = 2048, dkLen: Int = 64) -> Data? {
        var derivedKeyData = Data(repeating: 0, count: dkLen)
        let derivedCount = derivedKeyData.count
        
        let derivationStatus = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            password.withUnsafeBytes { passwordBytes in
                salt.withUnsafeBytes { saltBytes in
                    CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), passwordBytes, password.count, saltBytes, salt.count, CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512), c, derivedKeyBytes, derivedCount)
                }
            }
        }
        return derivationStatus == kCCSuccess ? derivedKeyData : nil
    }
}
