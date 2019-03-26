//
//  SHA256.swift
//

import Foundation
import CommonCrypto

extension Data {
    /**
     Hashes an input from some Data (self) using SHA256, and returns the digest as Data.
     */
    func SHA256() -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes { _ = CC_SHA256($0, CC_LONG(self.count), &hash) }
        
        return Data(bytes: hash)
    }
    
    /**
     Double Hashes data using SHA256, and returns the digest as Data.
     */
    func doubleSHA256() -> Data {
        return self.SHA256().SHA256()
    }
}

public struct HMAC_SHA256 {
    ///
    public static func digest(key: Data, data: Data) -> Data {
        let dataLen = data.count
        let keyLen = key.count
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
        CCHmac(algorithm, NSData(data: key).bytes, keyLen, NSData(data: data).bytes, dataLen, result)
        let returnData = NSData(bytesNoCopy: result, length: digestLen) as Data
        return returnData
    }
}

public struct HMAC_SHA512 {
    ///
    public static func digest(key: Data, data: Data) -> Data {
        let dataLen = data.count
        let keyLen = key.count
        let digestLen = Int(CC_SHA512_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA512)
        CCHmac(algorithm, NSData(data: key).bytes, keyLen, NSData(data: data).bytes, dataLen, result)
        let returnData = NSData(bytesNoCopy: result, length: digestLen) as Data
        return returnData
    }
}

