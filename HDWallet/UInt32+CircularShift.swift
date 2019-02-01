//
//  UInt32+CircularShift.swift
//  ripemd160

import Foundation

// Circular left shift: http://en.wikipedia.org/wiki/Circular_shift
// Precendence should be the same as <<
infix operator  ~<<: BitwiseShiftPrecedence

//FIXME: Make framework-only once tests support it
public func ~<< (lhs: UInt32, rhs: Int) -> UInt32 {
    return (lhs << UInt32(rhs)) | (lhs >> UInt32(32 - rhs));
}
