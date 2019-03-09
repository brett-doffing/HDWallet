//
//  RIPEMD.swift
//  ripemd160
//
// https://github.com/CryptoCoinSwift/RIPEMD-Swift

// Another implementation: https://stackoverflow.com/questions/43091858/swift-hash-a-string-using-hash-hmac-with-ripemd160/43191938

import Foundation

public struct RIPEMD {
    public static func digest (input : Data, bitlength:Int = 160) -> Data {
        assert(bitlength == 160, "Only RIPEMD-160 is implemented")
        
        let paddedData = pad(data: input as NSData)
        
        var block = RIPEMD.Block()
        
        var i = 0
        while i < paddedData.length / 64 {
            let part = getWordsInSection(data: paddedData, i)
            block.compress(message: part)
            i += 1
        }
        
        return encodeWords(input: block.hash) as Data
    }
    
    // Pads the input to a multiple 64 bytes. First it adds 0x80 followed by zeros.
    // It then needs 8 bytes at the end where it writes the length (in bits, little endian).
    // If this doesn't fit it will add another block of 64 bytes.
    
    // FIXME: Make private once tests support it
    public static func pad(data: NSData) -> NSData {
        let paddedData = data.mutableCopy() as! NSMutableData
        
        // Put 0x80 after the last character:
        let stop: [UInt8] = [UInt8(0x80)] // 2^8
        paddedData.append(stop, length: 1)
        
        // Pad with zeros until there are 64 * k - 8 bytes.
        var numberOfZerosToPad: Int;
        if paddedData.length % 64 == 56 {
            // No padding needed
            numberOfZerosToPad = 0
        } else if paddedData.length % 64 < 56 {
            numberOfZerosToPad = 56 - (paddedData.length % 64)
        } else {
            // Add an extra round
            numberOfZerosToPad = 56 + (64 - paddedData.length % 64)
        }
        
        let zeroBytes = [UInt8](repeating: 0, count: numberOfZerosToPad)
        paddedData.append(zeroBytes, length: numberOfZerosToPad)
        
        // Append length of message:
        let length: UInt32 = UInt32(data.length) * 8
        let lengthBytes: [UInt32] = [length, UInt32(0x00_00_00_00)]
        paddedData.append(lengthBytes, length: 8)
        
        return paddedData as NSData
    }
    
    // Takes an NSData object of length k * 64 bytes and returns an array of UInt32
    // representing 1 word (4 bytes) each. Each word is in little endian,
    // so "abcdefgh" is now "dcbahgfe".
    // FIXME: Make private once tests support it
    public static func getWordsInSection(data: NSData, _ section: Int) -> [UInt32] {
        let offset = section * 64
        
        assert(data.length >= Int(offset + 64), "Data too short")
        
        var words: [UInt32] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        data.getBytes(&words, range: NSMakeRange(offset, 64))
        
        
        return words
    }
    
    // FIXME: Make private once tests support it
    public static func encodeWords(input: [UInt32]) -> NSData {
        let data = NSMutableData(bytes: input, length: 20)
        return data
    }
    
    // Returns a string representation of a hexadecimal number
    public static func digest (input : Data, bitlength:Int = 160) -> String {
        return digest(input: input, bitlength: bitlength).toHexString()
    }
    
    // Takes a string representation of a hexadecimal number
    public static func hexStringDigest (input : String, bitlength:Int = 160) -> Data {
        let data = input.hexStringData()
        return digest(input: data, bitlength: bitlength)
    }
    
    // Takes a string representation of a hexadecimal number and returns a
    // string represenation of the resulting 160 bit hash.
    public static func hexStringDigest (input : String, bitlength:Int = 160) -> String {
        let digest: Data = hexStringDigest(input: input, bitlength: bitlength)
        return digest.toHexString()
    }
    
    // Takes an ASCII string
    public static func asciiDigest (input : String, bitlength:Int = 160) -> Data {
        // Order of bytes is preserved; if the last character is dot, the last
        // byte is a dot.
        if let data: Data = input.data(using: String.Encoding.ascii) as Data? {
            return digest(input: data, bitlength: bitlength)
        } else {
            assert(false, "Invalid input")
            return Data()
        }
    }
    
    //     Takes an ASCII string and returns a hex string represenation of the
    //     resulting 160 bit hash.
    public static func asciiDigest (input : String, bitlength:Int = 160) -> String {
        return asciiDigest(input: input, bitlength: bitlength).toHexString()
    }
    
}
