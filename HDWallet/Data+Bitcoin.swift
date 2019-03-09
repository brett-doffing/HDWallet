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
    
}

#warning("TODO: Check to see if already exists in secp256k1.framework")
extension Array where Element == UInt8 {
    var data : Data{
        return Data(bytes:(self))
    }
}

#warning("TODO: Find out what 'Self' is here, and place below in separate file.")
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
