// ExtendedPrivateKey.swift

import Foundation

struct ExtendedPrivateKey {
    
    let raw: Data
    let chainCode: Data
    let depth: UInt8
    let fingerprint: UInt32
    let index: UInt32
    let network: BTCNetwork
    var hex: String {
        var extendedPrivateKeyData = Data()
        extendedPrivateKeyData += network.privateKeyVersion.bigEndian
        extendedPrivateKeyData += depth.littleEndian
        extendedPrivateKeyData += fingerprint.littleEndian
        extendedPrivateKeyData += index.littleEndian
        extendedPrivateKeyData += chainCode
        extendedPrivateKeyData += UInt8(0)
        extendedPrivateKeyData += raw
        let checksum = extendedPrivateKeyData.doubleSHA256().prefix(4)
        extendedPrivateKeyData += checksum
        return extendedPrivateKeyData.toHexString()
    }
    var base58: String {
        return self.hex.base58EncodeHexString()
    }
    
    init(seed: Data) {
        let key = "Bitcoin seed".data(using: .ascii)
        let hash = HMAC_SHA512.digest(key: key!, data: seed)
        
        self.raw = hash[0..<32]
        self.chainCode = hash[32..<64]
        self.depth = 0
        self.fingerprint = 0
        self.index = 0
        self.network = BTCNetwork.main
    }
    
    init(privateKey: Data, chainCode: Data, depth: UInt8, fingerprint: UInt32, index: UInt32, network: BTCNetwork) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.index = index.bigEndian
        self.network = network
    }
}