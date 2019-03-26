// BTCCurve.swift

import Foundation
import secp256k1

/// Singleton
class BTCCurve {
    
    static let shared = BTCCurve()
    
    // TODO: Make non-optional
    let context: secp256k1_context?
    let order = BInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    
    private init() {
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
                return serializedPubkey.hexDescription()
            }
        } else { return "" }
    }
    
    func ECDH(withPubkey publicKey: secp256k1_pubkey?, andPrivateKey privateKey: Data) -> Data? {
        if let ctx = context, var pubkey = publicKey {
            if !(secp256k1_ec_pubkey_tweak_mul(ctx, &pubkey, privateKey.bytes)) { return nil }
            var serializedPubkey = [UInt8](repeating: 0, count:33)
            var length = UInt(33)
            if !(secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &length, pubkey, [SECP256K1_FLAGS.SECP256K1_EC_COMPRESSED])) { return nil }
            return serializedPubkey.data
        }
        return nil
    }
    
    /// Multiplies tweak by generator point and adds to public key point.
    func add(_ publicKey: Data, _ tweak: Data) -> Data? {
        if let ctx = context {
            var pubkey = secp256k1_pubkey()
            if !secp256k1_ec_pubkey_parse(ctx, &pubkey, publicKey.bytes, UInt(publicKey.count)) { return nil }
            if !(secp256k1_ec_pubkey_tweak_add(ctx, &pubkey, tweak.bytes)) { return nil }
            var serializedPubkey = [UInt8](repeating: 0, count:33)
            var length = UInt(33)
            if !(secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &length, pubkey, [SECP256K1_FLAGS.SECP256K1_EC_COMPRESSED])) { return nil }
            return serializedPubkey.data
        } else { return nil }
    }
    
    func parsePubkey(_ publicKey: Data) -> secp256k1_pubkey? {
        if let ctx = context {
            var pubkey = secp256k1_pubkey()
            if !secp256k1_ec_pubkey_parse(ctx, &pubkey, publicKey.bytes, UInt(publicKey.count)) { return nil }
            return pubkey
        } else { return nil }
    }
    
    func getPubkeyForPrivateKey(_ hexPrivateKey: String) -> secp256k1_pubkey? {
        if let ctx = context {
            let privateKey = hexPrivateKey.unhexlify()
            var pubkey = secp256k1_pubkey()
            if !(secp256k1_ec_pubkey_create(ctx, &pubkey, privateKey)) { return nil }
            return pubkey
        } else { return nil }
    }
    
    func generatePublicKey(privateKey: Data, compressed: Bool = true) -> Data? {
        if let ctx = context {
            var pubkey = secp256k1_pubkey()
            if !(secp256k1_ec_pubkey_create(ctx, &pubkey, privateKey.bytes)) { return nil }
            var serializedPubkey: [UInt8]
            if compressed {
                serializedPubkey = [UInt8](repeating: 0, count:33)
                var length = UInt(33)
                if !(secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &length, pubkey, [SECP256K1_FLAGS.SECP256K1_EC_COMPRESSED])) { return nil }
            } else {
                serializedPubkey = [UInt8](repeating: 0, count:65)
                var length = UInt(65)
                if !(secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &length, pubkey, [SECP256K1_FLAGS.SECP256K1_EC_UNCOMPRESSED])) { return nil }
            }
            return serializedPubkey.data
        } else { return nil }
    }
    
    func sign(key: [UInt8], message: [UInt8]) -> (r: Data, s: Data)? {
        if let ctx = context {
            var signature = secp256k1_ecdsa_signature()
            #warning("TODO: noncefp uses secp256k1_nonce_function_default when set to nil")
            guard secp256k1_ecdsa_sign(ctx, &signature, message, key, nil, nil) == true else { return nil }
            let r = [UInt8](signature.data[0..<32])
            let s = [UInt8](signature.data[32..<64])
            return (r: r.data, s: s.data)
        } else { return nil }
    }
    
    func sign(key: [UInt8], message: [UInt8]) -> secp256k1_ecdsa_signature? {
        if let ctx = context {
            var signature = secp256k1_ecdsa_signature()
            #warning("TODO: noncefp uses secp256k1_nonce_function_default when set to nil")
            guard secp256k1_ecdsa_sign(ctx, &signature, message, key, nil, nil) == true else { return nil }
            return signature
        } else { return nil }
    }
    
    func encodeDER(signature: secp256k1_ecdsa_signature?) -> [UInt8]? {
        if let ctx = context, let sig = signature {
            // add 7 bytes to account for various encoding bytes
            var length = UInt(sig.data.count + 7)
            var output = [UInt8](repeating: 0, count:Int(length))
            guard secp256k1_ecdsa_signature_serialize_der(ctx, &output, &length, sig) else { return nil }
            return output
        } else { return nil }
    }
    
    #warning("TODO: Decode scriptPubKey to get pubkey, and move or make private func.")
    func appendDERbytes(encodedDERSig: [UInt8], hashType: UInt8, scriptPubKey: [UInt8], pubkey: [UInt8]) -> [UInt8] {
        var output = encodedDERSig
        output.append(hashType)
        let derLengthByte: UInt8 = UInt8(output.count)
        output.insert(derLengthByte, at: 0)
        #warning("TODO: Account for other scripts.")
        let scriptPubKeyCheck = [UInt8](scriptPubKey[0..<3]).data.hexString()
        if scriptPubKeyCheck == "76a914" {
            output.append(UInt8(pubkey.count))
            output += pubkey
        }
        return output
    }
}
