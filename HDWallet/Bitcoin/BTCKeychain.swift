// BTCKeychain.swift

import Foundation

class BTCKeychain {
    
    let extendedPublicKey: ExtendedPublicKey
    let extendedPrivateKey: ExtendedPrivateKey?
    let network: BTCNetwork
    let type: BTCKeychainType
    /// 2^31 = 2147483648
    let hardenedMin = UInt32(2147483648)
    ///
    lazy var address: String = {
        switch self.type {
        case .BIP49:
            let hashedPubkey = self.extendedPublicKey.publicKey.hash160()
            var script = Data()
            script += OP_0
            script += OP_NUMBYTES(hashedPubkey.count)
            script += hashedPubkey
            let payload = script.hash160()
            return (self.network.scriptHash + payload).base58CheckEncodedString
        case .BIP84:
            let addrCoder = SegwitAddrCoder()
            let hashedPubkey = self.extendedPublicKey.publicKey.hash160()
            do  { return try addrCoder.encode(hrp: self.network.bech32, version: 0, program: hashedPubkey) }
            catch { return "" }
        default:
            let hashedPubkey = self.extendedPublicKey.publicKey.hash160()
            return (self.network.publicKeyHash + hashedPubkey).base58CheckEncodedString
        }
    }()
    
    init(seed: Data, network: BTCNetwork = .main) {
        self.network = network
        self.extendedPrivateKey = ExtendedPrivateKey(seed: seed, network: self.network)
        self.extendedPublicKey = ExtendedPublicKey(extPrivateKey: self.extendedPrivateKey!)
        self.type = .master
    }
    
    init(withExtendedPrivateKey extPrvkey: ExtendedPrivateKey, type: BTCKeychainType = .master) {
        self.network = extPrvkey.network
        self.extendedPrivateKey = extPrvkey
        self.extendedPublicKey = ExtendedPublicKey(extPrivateKey: self.extendedPrivateKey!)
        self.type = type
    }
    
    init(withExtendedPublicKey extPubkey: ExtendedPublicKey, type: BTCKeychainType = .master) {
        self.network = extPubkey.network
        self.extendedPrivateKey = nil
        self.extendedPublicKey = extPubkey
        self.type = type
    }
    
    /// Private parent key → private child key
    private func CKDpriv(kPar: Data, cPar: Data, index i: UInt32) -> (kIndex: Data, cIndex: Data) {
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
        #warning("TODO: handle")
        // In case parse256(IL) ≥ n or ki = 0, the resulting key is invalid, and one should proceed with the next value for i. (Note: this has probability lower than 1 in 2^127.)
        return (kIndex: kI.data, cIndex: IR)
    }
    
    /// Public parent key → public child key
    private func CKDpub(KPar: Data, cPar: Data, index i: UInt32) -> (KIndex: Data, cIndex: Data) {
        var I: Data = Data()
        if i >= hardenedMin { /* return error */ }
        else {
            // let I = HMAC-SHA512(Key = cpar, Data = serP(Kpar) || ser32(i)).
            I = HMAC_SHA512.digest(key: cPar, data: (KPar + i.bigEndian))
        }
        // Split I into two 32-byte sequences, IL and IR.
        let IL = I[0..<32]
        let IR = I[32..<64]

        // The returned child key Ki is point(parse256(IL)) + Kpar.
        let Ki = BTCCurve.shared.add(KPar, IL)
        // The returned chain code ci is IR.
        #warning("TODO: handle")
        // In case parse256(IL) ≥ n or Ki is the point at infinity, the resulting key is invalid, and one should proceed with the next value for i.
        return (KIndex: Ki!, cIndex: IR)
    }
    
    /// Key Derivation
    func derivedKeychain(withPath path: String, andType type: BTCKeychainType = .derived) -> BTCKeychain? {
        if self.extendedPrivateKey == nil { // CKDpub
            let pathArray: [String] = path.components(separatedBy:"/")
            var parentPublicKey = self.extendedPublicKey.publicKey
            var parentChainCode = self.extendedPublicKey.chainCode
            var childPublicKey: Data
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
                    let indexedKey = CKDpub(KPar: parentPublicKey, cPar: parentChainCode, index: keyIndex)
                    childPublicKey = indexedKey.KIndex
                    childChainCode = indexedKey.cIndex
                    if i == pathArray.count - 1 {
                        #warning("TODO: Determine if hashing the public key is correct.")
                        let fingerprint = getFingerprint(forParentPubkey: parentPublicKey)
                        let xPub = ExtendedPublicKey(childPublicKey, childChainCode, UInt8(i), fingerprint, keyIndex, self.network)
                        newKeychain = BTCKeychain(withExtendedPublicKey: xPub, type: type)
                        return newKeychain
                    } else {
                        parentPublicKey = childPublicKey
                        parentChainCode = childChainCode
                    }
                }
            }
        } else { // CKDpriv
            let pathArray: [String] = path.components(separatedBy:"/")
            var parentPrivateKey = self.extendedPrivateKey?.privateKey
            var parentChainCode = self.extendedPrivateKey?.chainCode
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
                    let indexedKey = CKDpriv(kPar: parentPrivateKey!, cPar: parentChainCode!, index: keyIndex)
                    childPrivateKey = indexedKey.kIndex
                    childChainCode = indexedKey.cIndex
                    if i == pathArray.count - 1 {
                        let fingerprint = getFingerprint(forParentPrvkey: parentPrivateKey!)
                        let xPrv = ExtendedPrivateKey(privateKey: childPrivateKey, chainCode: childChainCode, depth: UInt8(i), fingerprint: fingerprint, index: keyIndex, network: self.network)
                        newKeychain = BTCKeychain(withExtendedPrivateKey: xPrv, type: type)
                        return newKeychain
                    } else {
                        parentPrivateKey = childPrivateKey
                        parentChainCode = childChainCode
                    }
                }
            }
        }
        return nil
    }
    
    func getFingerprint(forParentPrvkey parPrvkey: Data) -> UInt32 {
        let parentPubkey = BTCCurve.shared.generatePublicKey(privateKey: parPrvkey)
        let fingerprint: UInt32 = parentPubkey!.hash160().withUnsafeBytes { $0.pointee }
        return fingerprint
    }
    
    func getFingerprint(forParentPubkey parentPubkey: Data) -> UInt32 {
        let fingerprint: UInt32 = parentPubkey.hash160().withUnsafeBytes { $0.pointee }
        return fingerprint
    }
    
    func recieveKeychain(atIndex index: UInt32, withType type: BTCKeychainType = .derived) -> BTCKeychain? {
        return derivedKeychain(withPath: "0/\(index)", andType: type)
    }
    
    func changeKeychain(atIndex index: UInt32, withType type: BTCKeychainType = .derived) -> BTCKeychain? {
        return derivedKeychain(withPath: "1/\(index)", andType: type)
    }
    
    func keychain(atIndex index: UInt32, withType type: BTCKeychainType = .derived) -> BTCKeychain? {
        return derivedKeychain(withPath: "\(index)")
    }
}
