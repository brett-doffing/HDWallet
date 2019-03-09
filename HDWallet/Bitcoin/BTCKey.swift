// BTCKey.swift

import Foundation

class BTCKey {
    
    var privateKey: Data?
    var publicKey: Data?
    var address: String?
    
    init(withPrivateKey prvkey: Data, network: BTCNetwork = .main) {
        self.privateKey = prvkey
        let pubkey = BTCCurve.shared.generatePublicKey(privateKey: prvkey)
        self.publicKey = pubkey
        let hashedPk = hash160(pubkey: pubkey!)
        let modifiedPubKey = concatenateAddress(hashedPublicKey: hashedPk, network: network)
        self.address = modifiedPubKey.toHexString().base58CheckEncodeHexString()
    }
    
    init(withPublicKey pubkey: Data, network: BTCNetwork = .main) {
        self.publicKey = pubkey
        let hashedPk = hash160(pubkey: pubkey)
        let modifiedPubKey = concatenateAddress(hashedPublicKey: hashedPk, network: network)
        address = modifiedPubKey.toHexString().base58CheckEncodeHexString()
    }
    
    /**
     Performs two hash functions: sha256, then ripemd160.
     */
    private func hash160(pubkey: Data) -> Data {
        let hashedPubkey = pubkey.hashDataSHA256()
        let hash160: Data = RIPEMD.digest(input: hashedPubkey)
        return hash160
    }
    
    /**
     Concatenates the final address (version || payload || checksum).
     */
    private func concatenateAddress(hashedPublicKey: Data, network: BTCNetwork = .main) -> Data {
        let prependedPublicKey = [network.publicKeyHash].data + hashedPublicKey
        let checksum = prependedPublicKey.doubleSHA256().prefix(4)
        let modifiedPublicKey = prependedPublicKey + checksum
        return modifiedPublicKey
    }
    
}
