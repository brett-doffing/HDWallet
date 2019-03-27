// ExtendedPublicKey.swift

import Foundation

struct ExtendedPublicKey {
    
    let publicKey: Data
    let chainCode: Data
    let depth: UInt8
    let fingerprint: UInt32
    let index: UInt32
    let network: BTCNetwork
    public var raw: Data {
        var extendedPublicKeyData = Data()
        extendedPublicKeyData += network.publicKeyVersion.bigEndian
        extendedPublicKeyData += depth.littleEndian
        extendedPublicKeyData += fingerprint.littleEndian
        extendedPublicKeyData += index.littleEndian
        extendedPublicKeyData += chainCode
        extendedPublicKeyData += publicKey
        let checksum = extendedPublicKeyData.doubleSHA256().prefix(4)
        extendedPublicKeyData += checksum
        return extendedPublicKeyData
    }
    var base58: String {
        return self.raw.base58EncodedString()
    }
    
    init(extPrivateKey: ExtendedPrivateKey) {
        self.publicKey = try! BTCCurve.shared.generatePublicKey(privateKey: extPrivateKey.privateKey)
        self.chainCode = extPrivateKey.chainCode
        self.depth = extPrivateKey.depth
        self.fingerprint = extPrivateKey.fingerprint
        self.index = extPrivateKey.index
        self.network = extPrivateKey.network
    }
    
    init(_ publicKey: Data, _ chainCode: Data, _ depth: UInt8, _ fingerprint: UInt32, _ index: UInt32, _ network: BTCNetwork = .main) {
        self.publicKey = publicKey
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.index = index
        self.network = network
    }
}
