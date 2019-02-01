//
//  SMP+Bitcoin.swift
//

import Foundation

extension BInt {
    init(hex: String) {
        self.init(number: hex.lowercased(), withBase: 16)!
    }
    
    func hex() -> String {
        return self.asString(withBase: 16)
    }
    
    // Used namely for HD wallet serialization
    func atLeast4ByteHex() -> String {
        let hex = self.asString(withBase: 16)
        if hex.count < 8 {
            var newHex = hex
            while newHex.count < 8 { newHex.insert("0", at: newHex.startIndex) }
            return newHex
        }
        return hex
    }
}
