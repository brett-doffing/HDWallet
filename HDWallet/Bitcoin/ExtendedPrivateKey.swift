// ExtendedPrivateKey.swift

import Foundation

struct ExtendedPrivateKey {
    
    let privateKey: Data
    let chainCode: Data
    let depth: UInt8
    let fingerprint: UInt32
    let index: UInt32
    let network: BTCNetwork
    var raw: Data {
        var extendedPrivateKeyData = Data()
        extendedPrivateKeyData += network.privateKeyVersion.bigEndian
        extendedPrivateKeyData += depth.littleEndian
        extendedPrivateKeyData += fingerprint.littleEndian
        extendedPrivateKeyData += index.littleEndian
        extendedPrivateKeyData += chainCode
        extendedPrivateKeyData += UInt8(0)
        extendedPrivateKeyData += privateKey
        let checksum = extendedPrivateKeyData.doubleSHA256().prefix(4)
        extendedPrivateKeyData += checksum
        return extendedPrivateKeyData
    }
    var base58: String {
        return self.raw.base58EncodedString()
    }
    
    init(seed: Data, network: BTCNetwork = .main) {
        let key = "Bitcoin seed".data(using: .ascii)
        let hash = HMAC_SHA512.digest(key: key!, data: seed)
        
        self.privateKey = hash[0..<32]
        self.chainCode = hash[32..<64]
        self.depth = 0
        self.fingerprint = 0
        self.index = 0
        self.network = network
    }
    
    init(privateKey: Data, chainCode: Data, depth: UInt8, fingerprint: UInt32, index: UInt32, network: BTCNetwork) {
        self.privateKey = privateKey
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.index = index.bigEndian
        self.network = network
    }
}
