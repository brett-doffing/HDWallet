// BTCKey.swift

import Foundation

class BTCKey {
    
    var privateKey: String?
    var publicKey: String?
    var address: String?
    
    init(withPrivateKey prvkey: String, testnet: Bool = false) {
        privateKey = prvkey
        let pubkey = BTCCurve.shared.pubkeyForHexPrivateKey(prvkey)
        publicKey = pubkey
        let hashedPk = hash160(pubkey: pubkey)
        let modifiedPubKey = concatenateAddress(hashedPublicKey: hashedPk, testnet: testnet)
        address = modifiedPubKey.base58CheckEncodeHexString()
    }
    
    init(withPublicKey pubkey: String, testnet: Bool = false) {
        publicKey = pubkey
        let hashedPk = hash160(pubkey: pubkey)
        let modifiedPubKey = concatenateAddress(hashedPublicKey: hashedPk, testnet: testnet)
        address = modifiedPubKey.base58CheckEncodeHexString()
    }
    
    /**
     Performs two hash functions: sha256, then ripemd160.
     */
    private func hash160(pubkey: String) -> String {
        let pubKeyToHash: Data = pubkey.hexStringData()
        let hashedPubkeyHex: String = pubKeyToHash.hashDataSHA256().toHexString()
        let hash160: String = RIPEMD.hexStringDigest(input: hashedPubkeyHex)
        return hash160
    }
    
    /**
     Concatenates the final address (version || payload || checksum).
     */
    private func concatenateAddress(hashedPublicKey: String, testnet: Bool = false) -> String {
        let prependedPublicKey = prependVersionByte(hashedPublicKey: hashedPublicKey, testnet: testnet)
        let data = prependedPublicKey.hexStringData()
        let checksum = data.SHA256ChecksumHexString()
        let modifiedPublicKey = String(prependedPublicKey + checksum)
        return modifiedPublicKey
    }
    
    /**
     Prepends the version byte to the address according to network.
     */
    private func prependVersionByte(hashedPublicKey: String, testnet: Bool = false) -> String {
        var pubkey: String
        if testnet { pubkey = String("6f" + hashedPublicKey) }
        else { pubkey = String("00" + hashedPublicKey) }
        return pubkey
    }
}
