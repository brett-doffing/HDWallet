// BTCTransactionTests.swift

import XCTest
@testable import HDWallet
@testable import secp256k1

class BTCTransactionTests: XCTestCase {
    
    func testOneInOneOutTestnetTx() {
        let utxo = TxOutput()
        utxo.address = "mqiuzQahssG6YzDmd8t9A3oXtpi9uFAdnQ"
        utxo.n = 0
        utxo.satoshis = 919423
        utxo.script = "76a9146ff4536d48becdc2f9cf55f4f34d7f0b268dc83f88ac".unhexlify().data
        utxo.txid = "c291228357e8927c4c35b3211401e3a2e26b680a9ff5215eddd6aaf2310b3f32".unhexlify().bigToLittleEndian().data
        
        let utxos = [utxo]
        let addressArray = ["mwyTfAfJSNAA3xMCxrSWa71qXe7C7ByuSF"]
        let satoshisArray = [UInt64(909423)]
        var scriptSigs: [Data] = []
        var newRawTx = BTCTransaction.shared.createTX(scriptSigs: scriptSigs, satoshis: satoshisArray, receivingAddresses: addressArray, utxos: utxos)
        newRawTx += UInt32(0x00000001).littleEndian
        
        let doubleSha256 = newRawTx.doubleSHA256().bytes
        var privateKey = "cNM2T9Qd2cCuNrJMPL9X83R8dFWJd6rugZthJqjJes2MpjZCS5Qm".base58CheckDecode()!
        privateKey.removeFirst(); privateKey.removeLast()
        let signature: secp256k1_ecdsa_signature? = BTCCurve.shared.sign(key: privateKey, message: doubleSha256)
        let publicKey = BTCCurve.shared.generatePublicKey(privateKey: privateKey.data)
        let encodedSig = BTCCurve.shared.encodeDER(signature: signature, hashType: 0x01, pubkey: (publicKey?.bytes)!)
        scriptSigs.append(encodedSig!.data)
        newRawTx = BTCTransaction.shared.createTX(scriptSigs: scriptSigs, satoshis: satoshisArray, receivingAddresses: addressArray, utxos: utxos)
        
        XCTAssertEqual(newRawTx.toHexString(), "0100000001323f0b31f2aad6dd5e21f59f0a686be2a2e3011421b3354c7c92e857832291c2000000006b483045022100ce4de81af40c58836c0a62dc252c1a4832de6cd24f98ba333271d51c18be7a1f02204c5f45afc69ecb38948c9217959bb2b19f9859e4f6c81abd455790488557e561012103a7ff20231eecf4c67c019b329f8958a686510e1922ad2b37957424b02fd240eaffffffff016fe00d00000000001976a914b48556e2de495803e21ec650de6c07bfb35e252c88ac00000000")
    }
}
