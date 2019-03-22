//
//  Data+Bitcoin.swift
//

import Foundation

extension Data {
    
    var bytes : [UInt8]{
        return [UInt8](self)
    }
    
    /**
     Returns some Data input as a hexadecimal String
     */
    func toHexString() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
    
    /**
     Performs two hash functions: sha256, then ripemd160.
     */
    func hash160() -> Data {
        let hashedPubkey = self.hashDataSHA256()
        let hash160: Data = RIPEMD.digest(input: hashedPubkey)
        return hash160
    }
    
    func base58EncodedString() -> String {
        let alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
        var bytes = self
        var zerosCount = 0
        var length = 0
        
        for b in bytes {
            if b != 0 { break }
            zerosCount += 1
        }
        
        bytes.removeFirst(zerosCount)
        
        let size = bytes.count * 138 / 100 + 1
        
        var base58: [UInt8] = Array(repeating: 0, count: size)
        for b in bytes {
            var carry = Int(b)
            var i = 0
            
            for j in 0...base58.count-1 where carry != 0 || i < length {
                carry += 256 * Int(base58[base58.count - j - 1])
                base58[base58.count - j - 1] = UInt8(carry % 58)
                carry /= 58
                i += 1
            }
            
            assert(carry == 0)
            
            length = i
        }
        
        // skip leading zeros
        var zerosToRemove = 0
        var str = ""
        for b in base58 {
            if b != 0 { break }
            zerosToRemove += 1
        }
        base58.removeFirst(zerosToRemove)
        
        while 0 < zerosCount {
            str = "\(str)1"
            zerosCount -= 1
        }
        
        for b in base58 {
            str = "\(str)\(alphabet[String.Index(encodedOffset: Int(b))])"
        }
        
        return str
    }
    
    public var base58CheckEncodedString: String {
        let checksum = self.doubleSHA256().prefix(4)
        let dataPlusChecksum = self + checksum
        return dataPlusChecksum.base58EncodedString()
    }
    
    func XOR(keyData: Data) -> Data {
        var xorData = [UInt8]()
        for i in 0..<self.count { xorData.append(self[i] ^ keyData[i]) }
        return Data(bytes: xorData)
    }
    
}

// TODO: Check to see if already exists in secp256k1.framework
extension Array where Element == UInt8 {
    var data : Data{
        return Data(bytes:(self))
    }
    
    func bigToLittleEndian() -> [UInt8] {
        var littleEndianArray: [UInt8] = []
        for byte in self {
            littleEndianArray.insert(byte.littleEndian, at: 0)
        }
        return littleEndianArray
    }
}

protocol DataConvertable {
    static func +(lhs: Data, rhs: Self) -> Data
    static func +=(lhs: inout Data, rhs: Self)
}

extension DataConvertable {
    static func +(lhs: Data, rhs: Self) -> Data {
        var value = rhs
        let data = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
        return lhs + data
    }
    
    static func +=(lhs: inout Data, rhs: Self) {
        lhs = lhs + rhs
    }
}

extension UInt8: DataConvertable {}
extension UInt32: DataConvertable {}
