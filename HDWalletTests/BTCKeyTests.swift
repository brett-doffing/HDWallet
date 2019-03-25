// BTCKeyTests.swift

import XCTest
@testable import HDWallet

class BTCKeyTests: XCTestCase {

    func testGenerateAddress() {
        let key1 = BTCKey(withPrivateKey: "11095327A9E4921336E93834D8A93395476FC3665B59668459F9AFC9A3917461".hexStringData())
        let key2 = BTCKey(withPrivateKey: "2E04AA55FD3B8C0AD544D7940961C2E294F034E4A90BDA4A88D972E417C9DDAD".hexStringData(), network: .test)
        XCTAssertEqual(key1.address!, "1MRVoPUVzDk8SRk9VpFEuASrcFiigxBgtR")
        XCTAssertEqual(key2.address!, "mkP75UgGqrFaU2pD272wfCRJKzvC2iV5tg")
    }
    
    func testP2SH() {
        
        var privateKey1 = "5JaTXbAUmfPYZFRwrYaALK48fN6sFJp4rHqq2QSXs8ucfpE4yQU".base58CheckDecode()
        privateKey1?.removeFirst() // removes version byte
        var privateKey2 = "5Jb7fCeh1Wtm4yBBg3q3XbT6B525i17kVhy3vMC9AqfR6FH2qGk".base58CheckDecode()
        privateKey2?.removeFirst()
        var privateKey3 = "5JFjmGo5Fww9p8gvx48qBYDJNAzR9pmH5S389axMtDyPT8ddqmw".base58CheckDecode()
        privateKey3?.removeFirst()
        
        let publicKey1 = BTCCurve.shared.generatePublicKey(privateKey: (privateKey1?.data)!, compressed: false)
        let publicKey2 = BTCCurve.shared.generatePublicKey(privateKey: (privateKey2?.data)!, compressed: false)
        let publicKey3 = BTCCurve.shared.generatePublicKey(privateKey: (privateKey3?.data)!, compressed: false)
        XCTAssertEqual(publicKey1?.toHexString(), "0491bba2510912a5bd37da1fb5b1673010e43d2c6d812c514e91bfa9f2eb129e1c183329db55bd868e209aac2fbc02cb33d98fe74bf23f0c235d6126b1d8334f86")
        XCTAssertEqual(publicKey2?.toHexString(), "04865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac09ef122b1a986818a7cb624532f062c1d1f8722084861c5c3291ccffef4ec6874")
        XCTAssertEqual(publicKey3?.toHexString(), "048d2455d2403e08708fc1f556002f1b6cd83f992d085097f9974ab08a28838f07896fbab08f39495e15fa6fad6edbfb1e754e35fa1c7844c41f322a1863d46213")
        
        // Break up because it seems to be too slow to process in tests
        // UInt8(0x41) = OP_CODE to push 65 bytes onto stack
        let redeemScript1 = [OP_2].data + UInt8(0x41) + publicKey1!
        let redeemScript2 = [UInt8(0x41)].data + publicKey2! + UInt8(0x41)
        let redeemScript3 = publicKey3! + OP_3 + OP_CHECKMULTISIG
        let redeemScript = redeemScript1 + redeemScript2 + redeemScript3
        let hash = redeemScript.hash160()
        
        let address = ([BTCNetwork.main.scriptHash].data + hash).base58CheckEncodedString
        XCTAssertEqual(address, "3QJmV3qfvL9SuYo34YihAf3sRCW3qSinyC")
        
        // UInt(0x14) = OP_CODE to push 20 bytes onto stack
        let scriptPubKey = [OP_HASH160].data + [UInt8(0x14)].data + hash + OP_EQUAL
        XCTAssertEqual(scriptPubKey.toHexString(), "a914f815b036d9bbbce5e9f2a00abd1bf3dc91e9551087")
    }
    
}
