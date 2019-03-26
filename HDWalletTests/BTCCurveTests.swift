// BTCCurveTests.swift

import XCTest
@testable import HDWallet
@testable import secp256k1

class BTCCurveTests: XCTestCase {
    
    let prvkeys = ["11095327A9E4921336E93834D8A93395476FC3665B59668459F9AFC9A3917461",
                   "18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725",
                   "04448fd1be0c9c13a5ca0b530e464b619dc091b299b98c5cab9978b32b4a1b8b",
                   "6bfa917e4c44349bfdf46346d389bf73a18cec6bc544ce9f337e14721f06107b",
                   "46d32fbee043d8ee176fe85a18da92557ee00b189b533fce2340e4745c4b7b8c",
                   "4d3037cfd9479a082d3d56605c71cbf8f38dc088ba9f7a353951317c35e6c343",
                   "97b94a9d173044b23b32f5ab64d905264622ecd3eafbe74ef986b45ff273bbba",
                   "ce67e97abf4772d88385e66d9bf530ee66e07172d40219c62ee721ff1a0dca01",
                   "ef049794ed2eef833d5466b3be6fe7676512aa302afcde0f88d6fcfe8c32cc09",
                   "d3ea8f780bed7ef2cd0e38c5d943639663236247c0a77c2c16d374e5a202455b",
                   "efb86ca2a3bad69558c2f7c2a1e2d7008bf7511acad5c2cbf909b851eb77e8f3",
                   "18bcf19b0b4148e59e2bba63414d7a8ead135a7c2f500ae7811125fb6f7ce941"]
    let pubkeys = ["0359ddbf24ee3d88ce431dafb9f7a2b30cb5e5d811c4ae4347fa3c89fd1fcafbaa",
                   "0250863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b2352",
                   "024ce8e3b04ea205ff49f529950616c3db615b1e37753858cc60c1ce64d17e2ad8",
                   "03e092e58581cf950ff9c8fc64395471733e13f97dedac0044ebd7d60ccc1eea4d",
                   "029b5f290ef2f98a0462ec691f5cc3ae939325f7577fcaf06cfc3b8fc249402156",
                   "02094be7e0eef614056dd7c8958ffa7c6628c1dab6706f2f9f45b5cbd14811de44",
                   "031054b95b9bc5d2a62a79a58ecfe3af000595963ddc419c26dab75ee62e613842",
                   "03dac6d8f74cacc7630106a1cfd68026c095d3d572f3ea088d9a078958f8593572",
                   "02396351f38e5e46d9a270ad8ee221f250eb35a575e98805e94d11f45d763c4651",
                   "039d46e873827767565141574aecde8fb3b0b4250db9668c73ac742f8b72bca0d0",
                   "038921acc0665fd4717eb87f81404b96f8cba66761c847ebea086703a6ae7b05bd",
                   "03d51a06c6b48f067ff144d5acdfbe046efa2e83515012cf4990a89341c1440289"]
    let uncompressedPubkeys = ["0459ddbf24ee3d88ce431dafb9f7a2b30cb5e5d811c4ae4347fa3c89fd1fcafbaaf21f14907b8d98a069e673217dcaa10141090d3536090e689f13ef7c87dbcfaf",
                               "0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6",
                               "044ce8e3b04ea205ff49f529950616c3db615b1e37753858cc60c1ce64d17e2ad8b008f2d9fbd6902479c9645d565dc0ef8a149ab41d4f600666aba9df29afd52c",
                               "04e092e58581cf950ff9c8fc64395471733e13f97dedac0044ebd7d60ccc1eea4d9383cb946ac71b375b922ba33927c290139ce1c9c3ed8d682bf78aaa74b5a2b9",
                               "049b5f290ef2f98a0462ec691f5cc3ae939325f7577fcaf06cfc3b8fc24940215638213e17195579db41b3a8dc7d7132215f8a0fe277b8d6ed90539aa46775c59c",
                               "04094be7e0eef614056dd7c8958ffa7c6628c1dab6706f2f9f45b5cbd14811de4457de7a6408386e0964674e15280eb5c7855b3755a09b5c770dfd65c4533717b6",
                               "041054b95b9bc5d2a62a79a58ecfe3af000595963ddc419c26dab75ee62e61384232957a66d6e790073e7a50ee0a0f8e0f153ff3f454799e1d01593e35f5bd49d3",
                               "04dac6d8f74cacc7630106a1cfd68026c095d3d572f3ea088d9a078958f8593572d36d0711f04c0651290e3b0bde133631caa92011ffc164a58e747cb38bcba18d",
                               "04396351f38e5e46d9a270ad8ee221f250eb35a575e98805e94d11f45d763c46519212423ff4e57fef66f7b3b0b1a10ad2f6baecb53d71c52eef895c04334ae8c6",
                               "049d46e873827767565141574aecde8fb3b0b4250db9668c73ac742f8b72bca0d04c3f4b62ebe84deb9a945c07088220760cd5a9d111852a8c7e8ab4d1445beb73",
                               "048921acc0665fd4717eb87f81404b96f8cba66761c847ebea086703a6ae7b05bd14e31be72110cf0ab06ff65f8e5deee6559cfda5654aebcb820fad548c5007e1",
                               "04d51a06c6b48f067ff144d5acdfbe046efa2e83515012cf4990a89341c1440289fe4c2164cd2637d38d9b9fa33c7d3acf4495a936feb1aa706c0c432c6f66be0d"]
    
    
    func testCompressedPublicKeys() {
        self.measure {
            for i in 0..<prvkeys.count {
                let privateKey = prvkeys[i].hexStringData()
                let publicKey = BTCCurve.shared.generatePublicKey(privateKey: privateKey)
                XCTAssertEqual(publicKey?.hexString(), pubkeys[i])
            }
        }
    }
    
    func testUncompressedPublicKeys() {
        self.measure {
            for i in 0..<prvkeys.count {
                let privateKey = prvkeys[i].hexStringData()
                let publicKey = BTCCurve.shared.generatePublicKey(privateKey: privateKey, compressed: false)
                XCTAssertEqual(publicKey?.hexString(), uncompressedPubkeys[i])
            }
        }
    }
    
    func testSign() {
        let pk1: [UInt8] = [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01]
        let message = "Satoshi Nakamoto".data(using: .utf8)!
        let hashedMessage = message.SHA256()
        let signature:(r: Data, s: Data)? = BTCCurve.shared.sign(key: pk1, message: hashedMessage.bytes)
        let r = "934b1ea10a4b3c1757e2b0c017d0b6143ce3c9a7e6a4a49860d7a6ab210ee3d8"
        let s = "2442ce9d2b916064108014783e923ec36b49743e2ffa1c4496f01a512aafd9e5"
        XCTAssertEqual(signature!.r.hexString(), r)
        XCTAssertEqual(signature!.s.hexString(), s)
    }
}
