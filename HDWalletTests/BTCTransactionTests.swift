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
        var encodedSig = BTCCurve.shared.encodeDER(signature: signature)
        encodedSig = BTCCurve.shared.appendDERbytes(encodedDERSig: encodedSig!, hashType: 0x01, scriptPubKey: utxo.script!.bytes, pubkey: publicKey!.bytes)
        scriptSigs.append(encodedSig!.data)
        newRawTx = BTCTransaction.shared.createTX(scriptSigs: scriptSigs, satoshis: satoshisArray, receivingAddresses: addressArray, utxos: utxos)
        
        XCTAssertEqual(newRawTx.hexString(), "0100000001323f0b31f2aad6dd5e21f59f0a686be2a2e3011421b3354c7c92e857832291c2000000006b483045022100ce4de81af40c58836c0a62dc252c1a4832de6cd24f98ba333271d51c18be7a1f02204c5f45afc69ecb38948c9217959bb2b19f9859e4f6c81abd455790488557e561012103a7ff20231eecf4c67c019b329f8958a686510e1922ad2b37957424b02fd240eaffffffff016fe00d00000000001976a914b48556e2de495803e21ec650de6c07bfb35e252c88ac00000000")
    }
    
    // https://bitcoin.org/en/developer-examples#complex-raw-transaction
    func testTwoInTwoOutTestnetTx() {
        let utxo1 = TxOutput()
        utxo1.address = "n2KprMQm4z2vmZnPMENfbp2P1LLdAEFRjS"
        utxo1.n = 0
        utxo1.satoshis = 5000000000
        utxo1.script = "210229688a74abd0d5ad3b06ddff36fa9cd8edd181d97b9489a6adc40431fb56e1d8ac".unhexlify().data
        utxo1.txid = "78203a8f6b529693759e1917a1b9f05670d036fbb129110ed26be6a36de827f3".unhexlify().bigToLittleEndian().data
        let utxo2 = TxOutput()
        utxo2.address = "muhtvdmsnbQEPFuEmxcChX58fGvXaaUoVt"
        utxo2.n = 0
        utxo2.satoshis = 4000000000
        utxo2.script = "76a9149ba386253ea698158b6d34802bb9b550f5ce36dd88ac".unhexlify().data
        utxo2.txid = "263c018582731ff54dc72c7d67e858c002ae298835501d80200f05753de0edf0".unhexlify().bigToLittleEndian().data
        
        let utxos = [utxo1, utxo2]
        let addressArray = ["n4puhBEeEWD2VvjdRC9kQuX2abKxSCMNqN", "n4LWXU59yM5MzQev7Jx7VNeq1BqZ85ZbLj"]
        let satoshisArray = [UInt64(7999990000), UInt64(1000000000)]
        var scriptSigs: [Data] = []
        var newRawTx = BTCTransaction.shared.createTX(scriptSigs: scriptSigs, satoshis: satoshisArray, receivingAddresses: addressArray, utxos: utxos)
        newRawTx += UInt32(0x00000001).littleEndian
        var doubleSha256 = newRawTx.doubleSHA256().bytes
        
        var privateKey1 = "cSp57iWuu5APuzrPGyGc4PGUeCg23PjenZPBPoUs24HtJawccHPm".base58CheckDecode()!
        var privateKey2 = "cT26DX6Ctco7pxaUptJujRfbMS2PJvdqiSMaGaoSktHyon8kQUSg".base58CheckDecode()!
        privateKey1.removeFirst(); privateKey1.removeLast(); privateKey2.removeFirst(); privateKey2.removeLast()
        
        let signature1: secp256k1_ecdsa_signature? = BTCCurve.shared.sign(key: privateKey1, message: doubleSha256)
        let publicKey1 = BTCCurve.shared.generatePublicKey(privateKey: privateKey1.data)
        var encodedSig1 = BTCCurve.shared.encodeDER(signature: signature1)
        encodedSig1 = BTCCurve.shared.appendDERbytes(encodedDERSig: encodedSig1!, hashType: 0x01, scriptPubKey: utxo1.script!.bytes, pubkey: publicKey1!.bytes)
        scriptSigs.append(encodedSig1!.data)
        
        newRawTx = BTCTransaction.shared.createTX(scriptSigs: scriptSigs, satoshis: satoshisArray, receivingAddresses: addressArray, utxos: utxos)
        newRawTx += UInt32(0x00000001).littleEndian
        doubleSha256 = newRawTx.doubleSHA256().bytes

        let signature2: secp256k1_ecdsa_signature? = BTCCurve.shared.sign(key: privateKey2, message: doubleSha256)
        let publicKey2 = BTCCurve.shared.generatePublicKey(privateKey: privateKey2.data)
        var encodedSig2 = BTCCurve.shared.encodeDER(signature: signature2)
        encodedSig2 = BTCCurve.shared.appendDERbytes(encodedDERSig: encodedSig2!, hashType: 0x01, scriptPubKey: utxo2.script!.bytes, pubkey: publicKey2!.bytes)
        scriptSigs.append(encodedSig2!.data)
        newRawTx = BTCTransaction.shared.createTX(scriptSigs: scriptSigs, satoshis: satoshisArray, receivingAddresses: addressArray, utxos: utxos)
        
        XCTAssertEqual(newRawTx.hexString(), "0100000002f327e86da3e66bd20e1129b1fb36d07056f0b9a117199e759396526b8f3a20780000000049483045022100ce5dd767430d42a9df1ac88d1bfd04a3fe4cf0ca3241c0bb143e76677528b9f702206f51396eab2c5c808c00d3ce3156774fa9c5b47e7190e6193dc952ab6e89e10c01fffffffff0ede03d75050f20801d50358829ae02c058e8677d2cc74df51f738285013c26000000006b483045022100b14bfacb90c6a4292fd0385ef94671ff26a8f14ab7086a6c1ac1ee6d64ae0cbd02203ed58ef3ef635cec3fc0dde9f7d33a7d9d0029ff7c0260b7bb73364e075add75012102240d7d3c7aad57b68aa0178f4c56f997d1bfab2ded3c2f9427686017c603a6d6ffffffff02f028d6dc010000001976a914ffb035781c3c69e076d48b60c3d38592e7ce06a788ac00ca9a3b000000001976a914fa5139067622fd7e1e722a05c17c2bb7d5fd6df088ac00000000")
    }
}
