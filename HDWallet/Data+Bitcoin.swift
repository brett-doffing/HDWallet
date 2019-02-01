//
//  Data+Bitcoin.swift
//

import Foundation

extension Data {
    /**
     Returns some Data input as a hexadecimal String
     */
    func toHexString() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}
