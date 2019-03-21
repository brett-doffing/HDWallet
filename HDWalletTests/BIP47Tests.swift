// BIP47Tests.swift

import XCTest
@testable import HDWallet

class BIP47Tests: XCTestCase {
    
    let alicePrvkey = "8d6a8ecd8ee5e0042ad0cb56e3a971c760b5145c3917a8e7beaf0ed92d7a520c"
    let bobPrvkeys = ["04448fd1be0c9c13a5ca0b530e464b619dc091b299b98c5cab9978b32b4a1b8b",
                      "6bfa917e4c44349bfdf46346d389bf73a18cec6bc544ce9f337e14721f06107b",
                      "46d32fbee043d8ee176fe85a18da92557ee00b189b533fce2340e4745c4b7b8c",
                      "4d3037cfd9479a082d3d56605c71cbf8f38dc088ba9f7a353951317c35e6c343",
                      "97b94a9d173044b23b32f5ab64d905264622ecd3eafbe74ef986b45ff273bbba",
                      "ce67e97abf4772d88385e66d9bf530ee66e07172d40219c62ee721ff1a0dca01",
                      "ef049794ed2eef833d5466b3be6fe7676512aa302afcde0f88d6fcfe8c32cc09",
                      "d3ea8f780bed7ef2cd0e38c5d943639663236247c0a77c2c16d374e5a202455b",
                      "efb86ca2a3bad69558c2f7c2a1e2d7008bf7511acad5c2cbf909b851eb77e8f3",
                      "18bcf19b0b4148e59e2bba63414d7a8ead135a7c2f500ae7811125fb6f7ce941"]
    let sharedSecrets = ["f5bb84706ee366052471e6139e6a9a969d586e5fe6471a9b96c3d8caefe86fef",
                         "adfb9b18ee1c4460852806a8780802096d67a8c1766222598dc801076beb0b4d",
                         "79e860c3eb885723bb5a1d54e5cecb7df5dc33b1d56802906762622fa3c18ee5",
                         "d8339a01189872988ed4bd5954518485edebf52762bf698b75800ac38e32816d",
                         "14c687bc1a01eb31e867e529fee73dd7540c51b9ff98f763adf1fc2f43f98e83",
                         "725a8e3e4f74a50ee901af6444fb035cb8841e0f022da2201b65bc138c6066a2",
                         "521bf140ed6fb5f1493a5164aafbd36d8a9e67696e7feb306611634f53aa9d1f",
                         "5f5ecc738095a6fb1ea47acda4996f1206d3b30448f233ef6ed27baf77e81e46",
                         "1e794128ac4c9837d7c3696bbc169a8ace40567dc262974206fcf581d56defb4",
                         "fe36c27c62c99605d6cd7b63bf8d9fe85d753592b14744efca8be20a4d767c37"]

    func testECDH() {
        for i in 0..<bobPrvkeys.count {
            let bobPubkey = BTCCurve.shared.getPubkeyForPrivateKey(bobPrvkeys[i])
            let ecdhResult = BTCCurve.shared.ECDH(withPubkey: bobPubkey, andPrivateKey: alicePrvkey.unhexlify().data)
            // Remove 1 byte prefix (parity sign)
            XCTAssertEqual(ecdhResult![1...].toHexString(), sharedSecrets[i])
        }
    }

}
