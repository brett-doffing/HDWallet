// BIP47.swift

import Foundation

/// Singleton
class BIP47 {
    
    static let shared = BIP47()
    
    /// Creates a keychain from acquired payment code to derive keys and addresses for tunnels/channels.
    func keychain(forPaymentCode paymentCode: String, network: BTCNetwork = .main) -> BTCKeychain {
        let payCodeData: [UInt8] = paymentCode.base58CheckDecode()!
        let pubkey = [UInt8](payCodeData[6..<72])
        let chainCode = [UInt8](payCodeData[72..<136])
        let depth = UInt8(3)
        #warning("TODO: determine if the initial fingerprint should be zero, or if it even matters.")
        let fingerprint: UInt32 = 0x00000000
        let index: UInt32 = 0x80000000
        let xPub = ExtendedPublicKey(pubkey.data, chainCode.data, depth, fingerprint, index.bigEndian)
        return BTCKeychain(withExtendedPublicKey: xPub)
    }
    
    func paymentCode(forBIP47Keychain keychain: BTCKeychain, _ version: UInt8 = 0x01) -> String {
        // TODO: verify BIP47 keychain?
        var paymentCode = Data()
        paymentCode += UInt8(0x47)
        paymentCode += version
        paymentCode += UInt8(0x00) // Features bit field. Bit 0: Bitmessage notification, Bits 1-7: reserved.
        paymentCode += keychain.extendedPublicKey!.publicKey
        paymentCode += keychain.extendedPublicKey!.chainCode
        paymentCode += Data(repeating: 0x00, count: 13) // Bytes 67 - 79: reserved for future expansion, zero-filled unless otherwise noted
        return paymentCode.base58CheckEncodedString
    }
    
    func getReceiveKey(forReceivingKeychain receiver: BTCKeychain, atKeyIndex keyIndex: UInt32, andSendingKeychain sender: BTCKeychain, atAccountIndex acctIndex: UInt32) -> BTCKey {
        // Assumes BIP47 keychains: m/47'/0'/0'
        
        let senderPrvkey = sender.key(atIndex: acctIndex).privateKey!
        let pubkeyData = receiver.key(atIndex: keyIndex).publicKey!
        let receiverPubkey = BTCCurve.shared.parsePubkey(pubkeyData)!
        let secretPoint = BTCCurve.shared.ECDH(withPubkey: receiverPubkey, andPrivateKey: senderPrvkey)!
        // Remove 1 byte prefix (parity sign)
        let x = Data(secretPoint[1...])
        #warning("TODO: If the value of s is not in the secp256k1 group, sender MUST increment the index used to derive receiver's public key and try again.")
        let s = x.SHA256()
        let Bp = BTCCurve.shared.add(pubkeyData, s)!
        return BTCKey(withPublicKey: Bp)
    }
    
    func createBlindedPaymentCode(forReceivingKeychain receiver: BTCKeychain, andSendingKeychain sender: BTCKeychain, withUTXO utxo: TxOutput, andOutpointPrvKey outpointPrvKey: Data) -> Data {
        // Assumes BIP47 keychains: m/47'/0'/0'
        
        let pubkeyData = receiver.key(atIndex: 0).publicKey!
        let receiverPubkey = BTCCurve.shared.parsePubkey(pubkeyData)!
        let secretPoint = BTCCurve.shared.ECDH(withPubkey: receiverPubkey, andPrivateKey: outpointPrvKey)!
        // Remove 1 byte prefix (parity sign)
        let x = Data(secretPoint[1...])
        let outpoint = Data(utxo.txid!.bytes.bigToLittleEndian().data + utxo.n!.littleEndian)
        let s = HMAC_SHA512.digest(key: outpoint, data: x)
        let f32 = s[0..<32]
        let l32 = s[32..<64]
        let senderPubkey = sender.extendedPublicKey?.publicKey
        #warning("FIXME: Find out why XOR() won't play nice unless arguments are explicitly recast!?")
        let xP = Data(senderPubkey![1...]).XOR(keyData: f32)
        let c: Data = (sender.extendedPublicKey?.chainCode)!
        let cP = Data(c).XOR(keyData: Data(l32))
        
        // Payment code payload after blinding:
        var blindedPaymentCode = Data()
        blindedPaymentCode += UInt8(0x01) // version byte
        blindedPaymentCode += UInt8(0x00) // features byte
        blindedPaymentCode += senderPubkey![0] // pubkey sign
        blindedPaymentCode += xP
        blindedPaymentCode += cP
        blindedPaymentCode += Data(repeating: 0x00, count: 13)
    
        return blindedPaymentCode
    }

}
