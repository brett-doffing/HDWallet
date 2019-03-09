// BTCCurve.swift

import Foundation
import secp256k1

class BTCCurve {
    
    static let shared = BTCCurve()
    
    // TODO: Make non-optional
    let context: secp256k1_context?
    let order = BInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    
    /*private*/ init() {
        self.context = secp256k1_context_create([SECP256K1_FLAGS.SECP256K1_CONTEXT_SIGN, SECP256K1_FLAGS.SECP256K1_CONTEXT_VERIFY])
    }
    
    func pubkeyForHexPrivateKey(_ hexPrivateKey: String, compressed: Bool = true) -> String {
        if let ctx = context {
            let privateKey = hexPrivateKey.unhexlify()
//            let boolVerified = secp256k1_ec_seckey_verify(ctx, privateKey)
            var pubkey = secp256k1_pubkey()
            if !(secp256k1_ec_pubkey_create(ctx, &pubkey, privateKey)) { return "" }
            if compressed {
                var serializedPubkey = [UInt8](repeating: 0, count:33)
                var length = UInt(33)
                if !(secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &length, pubkey, [SECP256K1_FLAGS.SECP256K1_EC_COMPRESSED])) { return "" }
                return serializedPubkey.hexDescription()
            } else {
                var serializedPubkey = [UInt8](repeating: 0, count:65)
                var length = UInt(65)
                if !(secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &length, pubkey, [SECP256K1_FLAGS.SECP256K1_EC_UNCOMPRESSED])) { return "" }
//                if !(secp256k1_ec_pubkey_parse(ctx, &pubkey, serializedPubkey, UInt(serializedPubkey.count)))
                return serializedPubkey.hexDescription()
            }
        } else { return "" }
    }
    
    func ECDH(withPubkey publicKey: secp256k1_pubkey?, andPrvkey hexPrivateKey: String) -> String {
        if let ctx = context, var pubkey = publicKey {
            let privateKey = hexPrivateKey.unhexlify()
            if !(secp256k1_ec_pubkey_tweak_mul(ctx, &pubkey, privateKey)) { return "" }
            var serializedPubkey = [UInt8](repeating: 0, count:33)
            var length = UInt(33)
            if !(secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &length, pubkey, [SECP256K1_FLAGS.SECP256K1_EC_COMPRESSED])) { return "" }
            return serializedPubkey.hexDescription()
        }
        return ""
    }
    
    /// Multiplies input by generator point and adds to public key point.
    func add(generatorMultipliedBy hexString: String, toPubkey publicKey: secp256k1_pubkey?) -> String {
        if let ctx = context, var pubkey = publicKey {
            let s = hexString.unhexlify()
            if !(secp256k1_ec_pubkey_tweak_add(ctx, &pubkey, s)) { return "" }
            var serializedPubkey = [UInt8](repeating: 0, count:33)
            var length = UInt(33)
            if !(secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &length, pubkey, [SECP256K1_FLAGS.SECP256K1_EC_COMPRESSED])) { return "" }
            return serializedPubkey.hexDescription()
        } else { return "" }
    }
    
    func getPubkeyForPrivateKey(_ hexPrivateKey: String) -> secp256k1_pubkey? {
        if let ctx = context {
            let privateKey = hexPrivateKey.unhexlify()
            var pubkey = secp256k1_pubkey()
            if !(secp256k1_ec_pubkey_create(ctx, &pubkey, privateKey)) { return nil }
            return pubkey
        } else { return nil }
    }
    
    func generatePublicKey(privateKey: Data) -> Data? {
        if let ctx = context {
            var pubkey = secp256k1_pubkey()
            if !(secp256k1_ec_pubkey_create(ctx, &pubkey, privateKey.bytes)) { return nil }
            var serializedPubkey = [UInt8](repeating: 0, count:33)
            var length = UInt(33)
            if !(secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &length, pubkey, [SECP256K1_FLAGS.SECP256K1_EC_COMPRESSED])) { return nil }
            return serializedPubkey.data
        } else { return nil }
    }
}
