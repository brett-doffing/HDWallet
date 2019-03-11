//
//  SHA256.swift
//

import Foundation
import CommonCrypto

extension String {
    /**
     Hashes any input string (self) using SHA256, and returns the digest as Data.
     */
    func hashSHA256() -> String {
//        let messageData = self.data(using:.utf8)!
//
//        return messageData.hashDataSHA256().toHexString()
        // TODO: Make similar to Data extension
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData.toHexString()
    }
    
    /**
     Double Hashes a hexadecimal string using SHA256, and returns the digest as a hexadecimal String.
     */
    func doubleSHA256() -> String {
        return self.hexStringData().doubleSHA256ToString()
    }
    
    /**
     Returns hexadecimal representation of a private key hashed from string input
     */
    func createPrivateKey() -> String {
        return self.hashSHA256()
    }
}

extension Data {
    /**
     Hashes an input from some Data (self) using SHA256, and returns the digest as Data.
     */
    func hashDataSHA256() -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes { _ = CC_SHA256($0, CC_LONG(self.count), &hash) }
        
        return Data(bytes: hash)
    }
    
    /**
     Double Hashes data using SHA256, and returns the digest as a hexadecimal String.
     */
    func doubleSHA256ToString() -> String {
        return self.hashDataSHA256().hashDataSHA256().toHexString()
    }
    
    /**
     Double Hashes data using SHA256, and returns the digest as Data.
     */
    func doubleSHA256() -> Data {
        return self.hashDataSHA256().hashDataSHA256()
    }
    
    func SHA256ChecksumHexString() -> String {
        let doubleSHA256 = self.doubleSHA256ToString()
        // Grab first 4 bytes
        let checksum = doubleSHA256.substring(to: doubleSHA256.index(doubleSHA256.startIndex, offsetBy: 8))
        
        return checksum
    }
    
    /**
     Returns hexadecimal representation of a private key hashed from data input
     */
    func createPrivateKey() -> String {
        let hashedInput = self.hashDataSHA256()
        let hexOfHash = hashedInput.toHexString()
        
        return hexOfHash
    }
}

public struct HMAC_SHA256 {
    /// Takes in a hexadecimal key and some hexadecimal data
    public static func digest(withKey key: String, andData dataString: String) -> String {
        let dataStr = dataString.hexToBitString().bitStringToByteArray()
        let dataLen = dataStr.count
        let keyStr = key.hexToBitString().bitStringToByteArray()
        let keyLen = keyStr.count
        
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
        
        CCHmac(algorithm, keyStr, keyLen, dataStr, dataLen, result)
        
        let data = NSData(bytesNoCopy: result, length: digestLen) as Data
        let hash = data.toHexString()
        
        return hash
    }
}

public struct HMAC_SHA512 {
    /// Takes in a hexadecimal key and some hexadecimal data
    public static func digest(withKey key: String, andDataString dataString: String) -> String {
        let dataStr = dataString.hexToBitString().bitStringToByteArray()
        let dataLen = dataStr.count
        let keyStr = key.hexToBitString().bitStringToByteArray()
        let keyLen = keyStr.count
        
        let digestLen = Int(CC_SHA512_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA512)
        
        CCHmac(algorithm, keyStr, keyLen, dataStr, dataLen, result)
        
        let data = NSData(bytesNoCopy: result, length: digestLen) as Data
        let hash = data.toHexString()
        
        return hash
    }
    
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
