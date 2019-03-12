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
    
    /**
     Encodes a hexadecimal string to base 58 encoding.
     */
    func base58EncodeHexString() -> String {
        var big = BInt(hex: self)
        var base58encodedString = ""
        let code_string: [Character] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
        while big > 0 {
            let bigRemainder  = big % 58
            let remainder = bigRemainder.toInt()
            base58encodedString = String("\(code_string[remainder!])\(base58encodedString)")
            big = big/58
        }
        return base58encodedString
    }
    
    /**
     Encodes a hexadecimal string to base58check encoding. Bitcoin addresses are implemented using the Base58Check encoding of the hash of either, P2SH or P2PKH addresses.
     */
    func base58CheckEncodeHexString() -> String {
        // Get leading zero bytes
        var checkLeadingZeros = true
        var leadingZeroCount = 0
        while checkLeadingZeros {
            let myIndex = self.index(startIndex, offsetBy: leadingZeroCount)
            if self[myIndex] == "0" {
                leadingZeroCount += 1
            } else {
                checkLeadingZeros = false
            }
        }
        
        var big = BInt(hex: self)
        var base58CheckEncodedString = ""
        let code_string: [Character] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
        while big > 0 {
            let remainder  = (big % 58).toInt()
            base58CheckEncodedString = "\(code_string[remainder!])\(base58CheckEncodedString)"
            big = big/58
        }
        
        // Prepend
        if leadingZeroCount >= 2 {
            if leadingZeroCount % 2 == 0 {
                let padding = String(repeating: "1", count: leadingZeroCount/2)
                return "\(padding)\(base58CheckEncodedString)"
            } else {
                let padding = String(repeating: "1", count: (leadingZeroCount-1)/2)
                return "\(padding)\(base58CheckEncodedString)"
            }
        }
        
        return base58CheckEncodedString
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
        
        if checksum != calculatedChecksum { print("not equal"); return nil }
        return bytes
    }
    
    func hexToBitString() -> String {
        var returnString = ""
        for char in self {
            let strChar = String(char)
            let num = Int(strChar, radix:16)
            var binary = String(num!, radix:2)
            while binary.count < 4 { binary.insert("0", at: binary.startIndex) }
            returnString.append(binary)
        }
        
        return returnString
    }
    
    func bitStringToByteArray() -> Array<UInt8> {
        var returnArray: [UInt8] = []
        var bits = self
        while bits.count > 0 {
            let str8bits = String(bits[..<bits.index(bits.startIndex, offsetBy: 8)])
            let myInt = UInt8(str8bits, radix:2)
            returnArray.append(myInt!)
            bits = String(bits[bits.index(bits.startIndex, offsetBy: 8)...])
        }
        
        return returnArray
    }
    
    func stringWithRange(startingIndex: Int, endingIndex: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: startingIndex)
        let end = self.index(self.startIndex, offsetBy: endingIndex)
        let range = start..<end
        return String(self[range])
    }

}
