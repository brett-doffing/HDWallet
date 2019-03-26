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
    
    // https://gist.github.com/gavinandresen/3966071
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
        XCTAssertEqual(publicKey1?.hexString(), "0491bba2510912a5bd37da1fb5b1673010e43d2c6d812c514e91bfa9f2eb129e1c183329db55bd868e209aac2fbc02cb33d98fe74bf23f0c235d6126b1d8334f86")
        XCTAssertEqual(publicKey2?.hexString(), "04865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac09ef122b1a986818a7cb624532f062c1d1f8722084861c5c3291ccffef4ec6874")
        XCTAssertEqual(publicKey3?.hexString(), "048d2455d2403e08708fc1f556002f1b6cd83f992d085097f9974ab08a28838f07896fbab08f39495e15fa6fad6edbfb1e754e35fa1c7844c41f322a1863d46213")
                
        var redeemScript = Data()
        redeemScript += OP_2
        redeemScript += UInt8(0x41) // OP_CODE to push 65 bytes onto stack
        redeemScript += publicKey1!
        redeemScript += UInt8(0x41)
        redeemScript += publicKey2!
        redeemScript += UInt8(0x41)
        redeemScript += publicKey3!
        redeemScript += OP_3
        redeemScript += OP_CHECKMULTISIG
        let hash = redeemScript.hash160()
        
        let address = (BTCNetwork.main.scriptHash + hash).base58CheckEncodedString
        XCTAssertEqual(address, "3QJmV3qfvL9SuYo34YihAf3sRCW3qSinyC")
        
        var scriptPubKey = Data()
        scriptPubKey += OP_HASH160
        scriptPubKey += UInt8(0x14) // OP_CODE to push 20 bytes onto stack
        scriptPubKey += hash
        scriptPubKey += OP_EQUAL
        
        XCTAssertEqual(scriptPubKey.hexString(), "a914f815b036d9bbbce5e9f2a00abd1bf3dc91e9551087")
    }
    
    // https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki#test-vectors
    func testBIP49testnet() { // This should be a keychain test, but keychains don't support testnet yet, so this is just an example of P2WPKH-nested-in-P2SH.
        var privateKey = "cULrpoZGXiuC19Uhvykx7NugygA3k86b3hmdCeyvHYQZSxojGyXJ".base58CheckDecode()?.data
        privateKey?.removeFirst()
        privateKey?.removeLast()
        XCTAssertEqual(privateKey?.hexString(), "c9bdb49cfbaedca21c4b1f3a7803c34636b1d7dc55a717132443fc3f4c5867e8")
        
        let publicKey = BTCCurve.shared.generatePublicKey(privateKey: privateKey!)
        let keyHash = publicKey?.hash160()
        var scriptSig = Data()
        scriptSig += OP_0
        scriptSig += UInt8(0x14)
        scriptSig += keyHash!
        let addressBytes = scriptSig.hash160()
        let address = (BTCNetwork.test.scriptHash + addressBytes).base58CheckEncodedString
        XCTAssertEqual(address, "2Mww8dCYPUpKHofjgcXcBCEGmniw9CoaiD2")
    }
    
    // https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#examples
    func testBECH32() {
        let pubkey = "0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798".hexStringData()
        // For P2WPKH
        let keyHash = pubkey.hash160()
        // For P2WSH
        var script = Data()
        script += UInt8(0x21)
        script += pubkey
        script += OP_CHECKSIG
        let programData = script.SHA256()
        
        let mainP2WPKH = try? SegwitAddrCoder.init().encode(hrp: BTCNetwork.main.bech32, version: 0, program: keyHash)
        let testP2WPKH = try? SegwitAddrCoder.init().encode(hrp: BTCNetwork.test.bech32, version: 0, program: keyHash)
        let mainP2WSH = try? SegwitAddrCoder.init().encode(hrp: BTCNetwork.main.bech32, version: 0, program: programData)
        let testP2WSH = try? SegwitAddrCoder.init().encode(hrp: BTCNetwork.test.bech32, version: 0, program: programData)
        XCTAssertEqual(mainP2WPKH, "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4")
        XCTAssertEqual(testP2WPKH, "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx")
        XCTAssertEqual(mainP2WSH, "bc1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3")
        XCTAssertEqual(testP2WSH, "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7")
    }
    
}
