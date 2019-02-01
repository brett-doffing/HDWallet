//
//  SECP256K1.swift
//

/**
 Technical details
 As excerpted from Standards:
 
 The elliptic curve domain parameters over Fp associated with a Koblitz curve secp256k1 are specified by the sextuple T = (p,a,b,G,n,h) where the finite field Fp is defined by:
 
 p = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE FFFFFC2F
 = 2^256 - 2^32 - 2^9 - 2^8 - 2^7 - 2^6 - 2^4 - 1
 The curve E: y^2 = x^3+ax+b over Fp is defined by:
 
 a = 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
 b = 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000007
 The base point G in compressed form is:
 
 G = 02 79BE667E F9DCBBAC 55A06295 CE870B07 029BFCDB 2DCE28D9 59F2815B 16F81798
 and in uncompressed form is:
 
 G = 04 79BE667E F9DCBBAC 55A06295 CE870B07 029BFCDB 2DCE28D9 59F2815B 16F81798 483ADA77 26A3C465 5DA4FBFC 0E1108A8 FD17B448 A6855419 9C47D08F FB10D4B8
 Finally the order n of G and the cofactor are:
 
 n = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141
 h = 01
 Properties
 secp256k1 has characteristic p, it is defined over the prime field ℤp. Some other curves in common use have characteristic 2, and are defined over a binary Galois field GF(2n), but secp256k1 is not one of them.
 As the a constant is zero, the ax term in the curve equation is always zero, hence the curve equation becomes y^2 = x^3 + 7.
 */

// Link to possible efficiency information via parallel processing and specific Koblitz curve info:
// https://www.cse.buffalo.edu/faculty/miller/Courses/CSE633/george-gunner-Spring-2017-CSE633.pdf
// Other references:
// http://joye.site88.net/papers/Joy08fastecc.pdf
// https://gist.github.com/fomichev/9f9f4a11cd93196067a6ac10ed1a5686
// https://en.wikibooks.org/wiki/Cryptography/Prime_Curve/Jacobian_Coordinates

import Foundation

// TODO: Implement validation
class SECP256K1 {
    /// Equivalent to 2**256 - 2**32 - 2**9 - 2**8 - 2**7 - 2**6 - 2**4 - 1 or 2**256 - 2**32 - 977
    let p = BInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F")
    
    // Generator numbers
    let Gx = BInt(hex: "79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798")
    let Gy = BInt(hex: "483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8")
    let order = BInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    
    func jacobianAddition(point1: (x: BInt, y: BInt, z: BInt), point2: (x: BInt, y: BInt, z: BInt)) -> (x: BInt, y: BInt, z: BInt) {
        // http://www.hyperelliptic.org/EFD/g1p/auto-shortw-jacobian.html#add-2007-bl
        let X1 = point1.x, Y1 = point1.y, Z1 = point1.z, X2 = point2.x, Y2 = point2.y, Z2 = point2.z
        
        if Z1.isZero() {
            let X3 = X2, Y3 = Y2, Z3 = Z2
            return (x: X3, y: Y3, z: Z3)
        }
        if Z2.isZero() {
            let X3 = X1, Y3 = Y1, Z3 = Z1
            return (x: X3, y: Y3, z: Z3)
        }
        
        let Z1Z1 = Z1**2 % p
        let Z2Z2 = Z2**2 % p
        let U1 = X1*Z2Z2 % p
        let U2 = X2*Z1Z1 % p
        let S1 = Y1*Z2*Z2Z2 % p
        let S2 = Y2*Z1*Z1Z1 % p
        let H = U2-U1
        let I = (2*H)**2
        let J = H*I
        let r = 2*(S2-S1)
        // TODO: find/test if this is necessary, or an efficiency
//        if H.sign == r.sign { return jacobianDoubling(jacPoint: point1) }
        let V = U1*I
        let X3 = r**2-J-2*V % p
        let Y3 = r*(V-X3)-2*S1*J % p
        let Z3 = ((Z1+Z2)**2-Z1Z1-Z2Z2)*H % p
        
        return (x: X3, y: Y3, z: Z3)
    }
    
    func jacobianDoubling(jacPoint: (x: BInt, y: BInt, z: BInt)) -> (x: BInt, y: BInt, z: BInt) {
        // http://www.hyperelliptic.org/EFD/g1p/auto-shortw-jacobian.html#dbl-2009-l
        let X = jacPoint.x, Y = jacPoint.y, Z = jacPoint.z
        
        let A = X**2 % p
        let B = Y**2 % p
        let C = B**2 % p
        let D = 2*((X+B)**2-A-C)  % p
        let E = 3*A % p
        let F = E**2 % p
        let X3 = F-2*D % p
        let Y3 = E*(D-X3)-8*C % p
        let Z3 = 2*Y*Z % p
        
        return (x: X3, y: Y3, z: Z3)
    }
    
    // Left to right binary method for point multiplication
    func pointMultiplication(privateKey scalar:BInt) -> (x: BInt, y: BInt) {
        var k = scalar
        // Accumulator
        var R0: (x: BInt, y: BInt, z: BInt)?
        // P = generator point = R1 initially
        var R1 = (x:Gx, y:Gy, z: BInt(1))

        while (k > 0) {
            if k.isOdd() {
                if R0 != nil { R0 = jacobianAddition(point1: R0!, point2: R1) }
                else { R0 = R1 }
            }
            k = k/2
            R1 = jacobianDoubling(jacPoint: R1)
        }
        
        return affineFromJacobian(jacPoint: R0!)
    }
    
    func affineFromJacobian(jacPoint: (x: BInt, y: BInt, z: BInt)) -> (x: BInt, y: BInt) {
        let zinv = inverse(b: jacPoint.z, n: p)
        var zinvsq = zinv**2
        var xOut = (jacPoint.x*zinvsq) % p
        zinvsq = zinv*zinvsq
        var yOut = (jacPoint.y*zinvsq) % p
        if xOut.isNegative() { xOut += p }
        if yOut.isNegative() { yOut += p }
        
        return (x: xOut, y: yOut)
    }
    
    func inverse(b: BInt, n: BInt) -> BInt {
        var inv1 = BInt(1)
        var inv2 = BInt(0)
        var p = n
        var x = b
        
        while p != 1 && p != 0 {
            var temp = inv2
            inv2 = inv1 - inv2 * (x/p)
            inv1 = temp
            temp = p
            p = x % p
            x = temp
            if p < 0 { p += x }
        }
        return inv2
    }
    
    func parityIsEven(y: BInt) -> Bool {
        return y % 2 == 0 ? true : false
    }

}
