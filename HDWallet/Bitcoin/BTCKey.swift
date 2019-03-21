// BTCKey.swift

import Foundation

// TODO: Determine if class is necessary or redundant.
class BTCKey {
    
    var privateKey: Data?
    var publicKey: Data?
    var address: String?
    
    // TODO: Determine if necessary or redundant.
    init(withPrivateKey prvkey: Data, network: BTCNetwork = .main) {
        self.privateKey = prvkey
        let pubkey = BTCCurve.shared.generatePublicKey(privateKey: prvkey)
        self.publicKey = pubkey
        let hashedPk = pubkey!.hash160()
        let modifiedPubKey = concatenateAddress(hashedPublicKey: hashedPk, network: network)
        self.address = modifiedPubKey.toHexString().base58CheckEncodeHexString()
    }
    
    init(withPrivateKey prvkey: Data, andPublicKey pubkey: Data, network: BTCNetwork = .main) {
        self.privateKey = prvkey
        self.publicKey = pubkey
        let hashedPk = pubkey.hash160()
        let modifiedPubKey = concatenateAddress(hashedPublicKey: hashedPk, network: network)
        self.address = modifiedPubKey.toHexString().base58CheckEncodeHexString()
    }
    
    init(withPublicKey pubkey: Data, network: BTCNetwork = .main) {
        self.publicKey = pubkey
        let hashedPk = pubkey.hash160()
        let modifiedPubKey = concatenateAddress(hashedPublicKey: hashedPk, network: network)
        address = modifiedPubKey.toHexString().base58CheckEncodeHexString()
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
