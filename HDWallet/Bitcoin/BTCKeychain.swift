// BTCKeychain.swift

import Foundation

class BTCKeychain {
    
    var masterPrivateKey: Data
    var masterChainCode: Data
    var masterPublicKey: Data
    var key: BTCKey
    var extendedPublicKey: ExtendedPublicKey?
    var extendedPrivateKey: ExtendedPrivateKey?
    /// 2^31 = 2147483648
    let hardenedMin = UInt32(2147483648)
    
    init(seed: Data) {
        self.extendedPrivateKey = ExtendedPrivateKey(seed: seed)
        self.extendedPublicKey = ExtendedPublicKey(extPrivateKey: self.extendedPrivateKey!)
        self.masterPrivateKey = (self.extendedPrivateKey?.raw)!
        self.masterChainCode = (self.extendedPrivateKey?.chainCode)!
        self.masterPublicKey = (self.extendedPublicKey?.raw)!
    }
    
    init(withExtendedPrivateKey extPrvkey: ExtendedPrivateKey) {
        self.extendedPrivateKey = extPrvkey
        self.extendedPublicKey = ExtendedPublicKey(extPrivateKey: self.extendedPrivateKey!)
        self.masterPrivateKey = (self.extendedPrivateKey?.raw)!
        self.masterChainCode = (self.extendedPrivateKey?.chainCode)!
        self.masterPublicKey = (self.extendedPublicKey?.raw)!
    }
    
    func CKDPriv(kPar: Data, cPar: Data, index i: UInt32) -> (kIndex: Data, cIndex: Data){
        var I: Data
        // Check whether i ≥ 2^31 (whether the child is a hardened key)
        if i >= hardenedMin {
            // let I = HMAC-SHA512(Key = cpar, Data = 0x00 || ser256(kpar) || ser32(i)). (Note: The 0x00 pads the private key to make it 33 bytes long)
            I = HMAC_SHA512.digest(key: cPar, data: (Data(repeating: 0, count: 1) + kPar + i.bigEndian))
        } else {
            // let I = HMAC-SHA512(Key = cpar, Data = serP(point(kpar)) || ser32(i)).
            let parentPubkey = BTCCurve.shared.generatePublicKey(privateKey: kPar)
            I = HMAC_SHA512.digest(key: cPar, data: (parentPubkey! + i.bigEndian))
        }
        
        // Split I into two 32-byte sequences, IL and IR.
        let IL = I[0..<32]
        let IR = I[32..<64]
        
        // The returned child key ki is parse256(IL) + kpar (mod n).
        let kI = (BInt(data: IL) + BInt(data: kPar)) % BTCCurve.shared.order
        // The returned chain code ci is IR.
        // In case parse256(IL) ≥ n or ki = 0, the resulting key is invalid, and one should proceed with the next value for i. (Note: this has probability lower than 1 in 2^127.)
        return (kIndex: kI.data, cIndex: IR)
    }
    
    // Public parent key → public child key
//    func CKDpub(KPar: (x: BInt, y:BInt), cPar: String, index i: UInt32) -> (KIndex: String, cIndex: String) {
//        var I: String = ""
//        if i >= hardenedMin { /* return error */ }
//        else {
//            // let I = HMAC-SHA512(Key = cpar, Data = serP(Kpar) || ser32(i)).
//            var myHexData = String()
//            let parityIsEven = secp256k1.parityIsEven(y: KPar.y)
//            if parityIsEven { myHexData.append("02\(KPar.x.hex())\(BInt(i).atLeast4ByteHex())") }
//            else { myHexData.append("03\(KPar.x.hex())\(BInt(i).atLeast4ByteHex())") }
//            print(myHexData)
//            I = HMAC_SHA512.digest(withKey: cPar, andDataString: myHexData)
//        }
//        // Split I into two 32-byte sequences, IL and IR.
//        let IL = String(I[..<I.index(I.startIndex, offsetBy: 64)])
//        let IR = String(I[I.index(I.startIndex, offsetBy: 64)...])
//
//        // The returned child key Ki is point(parse256(IL)) + Kpar.
////        let kI = BInt(hex: IL) + KPar
//        // The returned chain code ci is IR.
//        // In case parse256(IL) ≥ n or Ki is the point at infinity, the resulting key is invalid, and one should proceed with the next value for i.
//        return (KIndex: "String", cIndex: IR)
//    }
    
    /// Private Key Derivation
    func derivedKeychain(withPath path: String) -> BTCKeychain? {
        let pathArray: [String] = path.components(separatedBy:"/")
        var parentPrivateKey = masterPrivateKey
        var parentChainCode = masterChainCode
        var childPrivateKey: Data
        var childChainCode: Data
        var newKeychain: BTCKeychain
        
        for i in 0..<pathArray.count {
            var pathComponent = pathArray[i]
            var keyIndex: UInt32
            if pathComponent != "m" {
                if pathComponent.last == "'" { // apostrophe character
                    pathComponent.removeLast()
                    keyIndex = UInt32(pathComponent)! + hardenedMin
                } else {
                    keyIndex = UInt32(pathComponent)!
                }
                let indexedKey = CKDPriv(kPar: parentPrivateKey, cPar: parentChainCode, index: keyIndex)
                childPrivateKey = indexedKey.kIndex
                childChainCode = indexedKey.cIndex
                if i == pathArray.count - 1 {
                    let fingerprint = getFingerprint(forParentPrvkey: parentPrivateKey)
                    let xPrv = ExtendedPrivateKey(privateKey: childPrivateKey, chainCode: childChainCode, depth: UInt8(i), fingerprint: fingerprint, index: keyIndex, network: BTCNetwork.main)
                    newKeychain = BTCKeychain(withExtendedPrivateKey: xPrv)
                    return newKeychain
                } else {
                    parentPrivateKey = childPrivateKey
                    parentChainCode = childChainCode
                }
            } else {
//                print("master")
            }
        }
        return nil
    }
    
    func getFingerprint(forParentPrvkey parPrvkey: Data) -> UInt32 {
        let parentPubkey = BTCCurve.shared.generatePublicKey(privateKey: parPrvkey)
        let fingerprint: UInt32 = hash160(pubkey: parentPubkey!).withUnsafeBytes { $0.pointee }
        return fingerprint
    }
    
    /// Duplicate of function used in BTCKey
    private func hash160(pubkey: Data) -> Data {
        let hashedPubkey = pubkey.hashDataSHA256()
        let hash160: Data = RIPEMD.digest(input: hashedPubkey)
        return hash160
    }
}
