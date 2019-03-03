// BTCCurve.swift

import Foundation
import secp256k1

class BTCCurve {
    
    static let shared = BTCCurve()
    
    // TODO: Make non-optional
    let context: secp256k1_context?
    
    /*private*/ init() {
        self.context = secp256k1_context_create([SECP256K1_FLAGS.SECP256K1_CONTEXT_SIGN, SECP256K1_FLAGS.SECP256K1_CONTEXT_VERIFY])
    }
    
    func pubkeyForHexPrivateKey(_ hexKey: String, compressed: Bool = true) -> String {
        if let ctx = context {
            let privateKey = hexKey.unhexlify()
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
        }
        return ""
    }
}
