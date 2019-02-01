//
//  HDWallet.swift
//
// REFERENCES:
// https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki

import Foundation

class HDWallet {
    
    let secp256k1 = SECP256K1()
    let masterSecretKey: String
    let masterChainCode: String
    // 2^31 = 2147483648
    let hardenedMin = BInt(2147483648)
    
    init(withHexSeed seed: String) {
        // (Key = "Bitcoin seed") as hex
        let hexKey = "426974636f696e2073656564"
        let hdMasterKey = HMAC_SHA512.digest(withKey: hexKey, andDataString: seed)
//        let hdMasterKey = HMAC_SHA512.digest(withKey: hexKey, andDataString: "fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542")
        
        self.masterSecretKey = String(hdMasterKey[..<hdMasterKey.index(hdMasterKey.startIndex, offsetBy: 64)])
        self.masterChainCode = String(hdMasterKey[hdMasterKey.index(hdMasterKey.startIndex, offsetBy: 64)...])
//        test()
    }
    
    func test() {
//        CKDpriv(kPar: masterSecretKey, cPar: masterChainCode, index: BInt(1))
//        CKDpriv(kPar: masterSecretKey, cPar: masterChainCode, index: hardenedMin)
    }
    
    // Private parent key → private child key
    // Child Key Derivation
    // TODO: more elegant conversion of i to bit string? Instead of i.hex().hexToBitString()
    func CKDpriv(kPar: String, cPar: String, index i: BInt) -> (kIndex: String, cIndex: String) {
        var I: String
        // Check whether i ≥ 2^31 (whether the child is a hardened key)
        if i >= hardenedMin {
            // let I = HMAC-SHA512(Key = cpar, Data = 0x00 || ser256(kpar) || ser32(i)). (Note: The 0x00 pads the private key to make it 33 bytes long)
            let myHexData = String("00" + kPar + i.hex())
            //            print(myHexData)
            I = HMAC_SHA512.digest(withKey: cPar, andDataString: myHexData)
        } else {
            // let I = HMAC-SHA512(Key = cpar, Data = serP(point(kpar)) || ser32(i)).
            var myHexData = String()
            let parentPublicKey = secp256k1.pointMultiplication(privateKey: BInt(hex: kPar))
            let parityIsEven = secp256k1.parityIsEven(y: parentPublicKey.y)
            if parityIsEven { myHexData.append("02\(parentPublicKey.x.hex())\(i.atLeast4ByteHex())") }
            else { myHexData.append("03\(parentPublicKey.x.hex())\(i.atLeast4ByteHex())") }
            //            print(myHexData)
            I = HMAC_SHA512.digest(withKey: cPar, andDataString: myHexData)
        }
        
        // Split I into two 32-byte sequences, IL and IR.
        let IL = String(I[..<I.index(I.startIndex, offsetBy: 64)])
        let IR = String(I[I.index(I.startIndex, offsetBy: 64)...])
        
        // The returned child key ki is parse256(IL) + kpar (mod n).
        let kI = (BInt(hex: IL) + BInt(hex: kPar)) % secp256k1.order
        // The returned chain code ci is IR.
        // In case parse256(IL) ≥ n or ki = 0, the resulting key is invalid, and one should proceed with the next value for i. (Note: this has probability lower than 1 in 2127.)
        return (kIndex: kI.hex(), cIndex: IR)
    }
    
    // Public parent key → public child key
    func CKDpub(KPar: (x: BInt, y:BInt), cPar: String, index i: BInt) -> (KIndex: String, cIndex: String) {
        var I: String = ""
        if i >= hardenedMin { /* return error */ }
        else {
            // let I = HMAC-SHA512(Key = cpar, Data = serP(Kpar) || ser32(i)).
            var myHexData = String()
            let parityIsEven = secp256k1.parityIsEven(y: KPar.y)
            if parityIsEven { myHexData.append("02\(KPar.x.hex())\(i.atLeast4ByteHex())") }
            else { myHexData.append("03\(KPar.x.hex())\(i.atLeast4ByteHex())") }
            print(myHexData)
            I = HMAC_SHA512.digest(withKey: cPar, andDataString: myHexData)
        }
        // Split I into two 32-byte sequences, IL and IR.
        let IL = String(I[..<I.index(I.startIndex, offsetBy: 64)])
        let IR = String(I[I.index(I.startIndex, offsetBy: 64)...])
        
        // The returned child key Ki is point(parse256(IL)) + Kpar.
//        let kI = BInt(hex: IL) + KPar
        // The returned chain code ci is IR.
        // In case parse256(IL) ≥ n or Ki is the point at infinity, the resulting key is invalid, and one should proceed with the next value for i.
        return (KIndex: "String", cIndex: IR)
    }
    
    func getPrivateKey(forPath path: String) {
        let myStringArr = path.components(separatedBy:"/")
        var parentSecretKey = masterSecretKey
        var parentChainCode = masterChainCode
        
        for var pathIndex in myStringArr {
            var intPath: BInt?
            if pathIndex != "m" {
                if pathIndex.last == "'" { // apostrophe character
                    pathIndex.removeLast()
                    intPath = BInt(pathIndex)! + hardenedMin
                } else {
                    intPath = BInt(pathIndex)!
                }
//                print(intPath)
                if intPath != nil {
                    let indexedKey = CKDpriv(kPar: parentSecretKey, cPar: parentChainCode, index: intPath!)
                    print("indexedSecretKey = \(indexedKey.kIndex)")
                    print("indexedChainCode = \(indexedKey.cIndex)")
                    parentSecretKey = indexedKey.kIndex
                    parentChainCode = indexedKey.cIndex
                }
            } else {
                print("masterSecretKey = \(masterSecretKey)")
                print("masterChainCode = \(masterChainCode)")
            }
        }
    }
}
