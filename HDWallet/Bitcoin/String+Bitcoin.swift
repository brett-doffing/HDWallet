//
//  String+Bitcoin.swift
//

import Foundation

extension String {
    /**
     Returns a hexadecimal String input as Data
     */
    func hexStringData() -> Data {
        var hex = self
        var data = Data()
        while(hex.count > 0) {
            let c: String = String(hex[..<hex.index(hex.startIndex, offsetBy: 2)])
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 2)...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
    
    func bytesFromBase58() -> [UInt8] {
        let alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
        // remove leading and trailing whitespaces
        let string = self.trimmingCharacters(in: CharacterSet.whitespaces)
        guard !string.isEmpty else { return [] }
        
        var zerosCount = 0
        var length = 0
        for c in string {
            if c != "1" { break }
            zerosCount += 1
        }
        
        let size = string.lengthOfBytes(using: String.Encoding.utf8) * 733 / 1000 + 1 - zerosCount
        var base58: [UInt8] = Array(repeating: 0, count: size)
        for c in string where c != " " {
            // search for base58 character
            guard let base58Index = alphabet.index(of: c) else { return [] }
            
            var carry = base58Index.encodedOffset
            var i = 0
            for j in 0...base58.count where carry != 0 || i < length {
                carry += 58 * Int(base58[base58.count - j - 1])
                base58[base58.count - j - 1] = UInt8(carry % 256)
                carry /= 256
                i += 1
            }
            assert(carry == 0)
            length = i
        }
        
        // skip leading zeros
        var zerosToRemove = 0
        for b in base58 {
            if b != 0 { break }
            zerosToRemove += 1
        }
        base58.removeFirst(zerosToRemove)
        
        var result: [UInt8] = Array(repeating: 0, count: zerosCount)
        for b in base58 {
            result.append(b)
        }
        return result
    }
    
    func base58CheckDecode() -> [UInt8]? {
        var bytes = self.bytesFromBase58()
        guard 4 <= bytes.count else { return nil }
        
        let checksum = [UInt8](bytes[bytes.count-4..<bytes.count])
        bytes = [UInt8](bytes[0..<bytes.count-4])
        
        let calculatedChecksum = Data(bytes: bytes).doubleSHA256().prefix(4).bytes
        
        if checksum != calculatedChecksum { return nil }
        return bytes
    }
}
