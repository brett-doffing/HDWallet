//
//  BTCAddress.swift
//

import Foundation

class BTCAddress {
    
    let secp256k1 = SECP256K1()
    var privateKey: BInt
    private var _address: String? // Used by property getter.
    var base58CheckEncodedHexString: String {
        get {
            if _address == nil { _address = getAddress(forPrivateKey: privateKey, testnet: false) }
            return _address!
        }
    }
    
    init(privateKey pk: BInt) {
        self.privateKey = pk
    }
    
    /**
     Generates a public address from a hashed (sha256) private key.
    */
    func getAddress(forPrivateKey privateKey: BInt, testnet: Bool) -> String {
        let publicKey = secp256k1.pointMultiplication(privateKey: privateKey)
        let hashedPk = hash160(publicKey: publicKey)
        let modifiedPubKey = concatenateAddressVersionPayloadAndChecksum(hashedPublicKey: hashedPk, testnet: testnet)
        let publicAddress = modifiedPubKey.base58CheckEncodeHexString()
        return publicAddress
    }
    
    /**
     Performs two hash functions: sha256, then ripemd160.
     */
    func hash160(publicKey: (x: BInt, y: BInt)) -> String {
        var pubKeyToHash: Data
        var hash160: String
        
        // UNCOMPRESSED
//        pubKeyToHash = "04\(publicKey.x.hex())\(publicKey.y.hex())".dataFromHexString()
        
        // COMPRESSED
        let parityIsEven = secp256k1.parityIsEven(y: publicKey.y)
        if parityIsEven { pubKeyToHash = "02\(publicKey.x.hex())".hexStringData() }
        else { pubKeyToHash = "03\(publicKey.x.hex())".hexStringData() }
        
        let hashedPubKeyHex = pubKeyToHash.hashDataSHA256().toHexString()
        hash160 = RIPEMD.hexStringDigest(input: hashedPubKeyHex)
        
        return hash160
    }
    
    /**
     Concatenates the final address (version || payload || checksum).
     */
    func concatenateAddressVersionPayloadAndChecksum(hashedPublicKey: String, testnet: Bool) -> String {
        let prependedPublicKey = prependVersionByteForPublicKey(hashedPublicKey: hashedPublicKey, testnet: testnet)
        let data = prependedPublicKey.hexStringData()
        let checksum = data.SHA256ChecksumHexString()
        let modifiedPK = String(prependedPublicKey + checksum)
        
        return modifiedPK
    }
    
    /**
     Prepends the version byte to the address according to network.
     */
    func prependVersionByteForPublicKey(hashedPublicKey: String, testnet: Bool) -> String {
        var pubK: String
        if testnet { pubK = String("6f" + hashedPublicKey) }
        else { pubK = String("00" + hashedPublicKey) }
        
        return pubK
    }
}
