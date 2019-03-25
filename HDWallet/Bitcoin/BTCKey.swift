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
        let prependedPublicKey = network.publicKeyHash + hashedPk
        self.address = prependedPublicKey.base58CheckEncodedString
    }
    
    init(withPrivateKey prvkey: Data, andPublicKey pubkey: Data, network: BTCNetwork = .main) {
        self.privateKey = prvkey
        self.publicKey = pubkey
        let hashedPk = pubkey.hash160()
        let prependedPublicKey = network.publicKeyHash + hashedPk
        self.address = prependedPublicKey.base58CheckEncodedString
    }
    
    init(withPublicKey pubkey: Data, network: BTCNetwork = .main) {
        self.publicKey = pubkey
        let hashedPk = pubkey.hash160()
        let prependedPublicKey = network.publicKeyHash + hashedPk
        self.address = prependedPublicKey.base58CheckEncodedString
    }
    
}
