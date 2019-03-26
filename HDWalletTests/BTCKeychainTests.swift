// BTCKeychainTests.swift

import XCTest
@testable import HDWallet

class BTCKeychainTests: XCTestCase { // TODO: need to add support for testnet keychains
    
    // https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vectors
    func testKeychains() {
        let seed = String("000102030405060708090a0b0c0d0e0f")
        let keyChain = BTCKeychain(seed: seed.hexStringData())
        XCTAssertEqual(keyChain.extendedPrivateKey?.base58, "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi")
        XCTAssertEqual(keyChain.extendedPublicKey.base58, "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8")
        var path = "m/0'"
        let m_0H = keyChain.derivedKeychain(withPath: path)
        XCTAssertEqual(m_0H?.extendedPrivateKey?.base58, "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7")
        XCTAssertEqual(m_0H?.extendedPublicKey.base58, "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw")
        path = "m/0'/1"
        let m_0H_1 = keyChain.derivedKeychain(withPath: path)
        XCTAssertEqual(m_0H_1?.extendedPrivateKey?.base58, "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs")
        XCTAssertEqual(m_0H_1?.extendedPublicKey.base58, "xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ")
        path = "m/0'/1/2'"
        let m_0H_1_2H = keyChain.derivedKeychain(withPath: path)
        XCTAssertEqual(m_0H_1_2H?.extendedPrivateKey?.base58, "xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM")
        XCTAssertEqual(m_0H_1_2H?.extendedPublicKey.base58, "xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5")
        path = "m/0'/1/2'/2"
        let m_0H_1_2H_2 = keyChain.derivedKeychain(withPath: path)
        XCTAssertEqual(m_0H_1_2H_2?.extendedPrivateKey?.base58, "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334")
        XCTAssertEqual(m_0H_1_2H_2?.extendedPublicKey.base58, "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV")
        path = "m/0'/1/2'/2/1000000000"
        let m_0H_1_2H_2_1000000000 = keyChain.derivedKeychain(withPath: path)
        XCTAssertEqual(m_0H_1_2H_2_1000000000?.extendedPrivateKey?.base58, "xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76")
        XCTAssertEqual(m_0H_1_2H_2_1000000000?.extendedPublicKey.base58, "xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy")
        
        let seed2 = String("fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542")
        let keyChain2 = BTCKeychain(seed: seed2.hexStringData())
        XCTAssertEqual(keyChain2.extendedPrivateKey?.base58, "xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U")
        XCTAssertEqual(keyChain2.extendedPublicKey.base58, "xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB")
        var path2 = "m/0"
        let m_0 = keyChain2.derivedKeychain(withPath: path2)
        XCTAssertEqual(m_0?.extendedPrivateKey?.base58, "xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt")
        XCTAssertEqual(m_0?.extendedPublicKey.base58, "xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH")
        path2 = "m/0/2147483647'"
        let m_0_2147483647H = keyChain2.derivedKeychain(withPath: path2)
        XCTAssertEqual(m_0_2147483647H?.extendedPrivateKey?.base58, "xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9")
        XCTAssertEqual(m_0_2147483647H?.extendedPublicKey.base58, "xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a")
        path2 = "m/0/2147483647'/1"
        let m_0_2147483647H_1 = keyChain2.derivedKeychain(withPath: path2)
        XCTAssertEqual(m_0_2147483647H_1?.extendedPrivateKey?.base58, "xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef")
        XCTAssertEqual(m_0_2147483647H_1?.extendedPublicKey.base58, "xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon")
        path2 = "m/0/2147483647'/1/2147483646'"
        let m_0_2147483647H_1_2147483646H = keyChain2.derivedKeychain(withPath: path2)
        XCTAssertEqual(m_0_2147483647H_1_2147483646H?.extendedPrivateKey?.base58, "xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc")
        XCTAssertEqual(m_0_2147483647H_1_2147483646H?.extendedPublicKey.base58, "xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL")
        path2 = "m/0/2147483647'/1/2147483646'/2"
        let m_0_2147483647H_1_2147483646H_2 = keyChain2.derivedKeychain(withPath: path2)
        XCTAssertEqual(m_0_2147483647H_1_2147483646H_2?.extendedPrivateKey?.base58, "xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j")
        XCTAssertEqual(m_0_2147483647H_1_2147483646H_2?.extendedPublicKey.base58, "xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt")
        
        let seed3 = String("4b381541583be4423346c643850da4b320e46a87ae3d2a4e6da11eba819cd4acba45d239319ac14f863b8d5ab5a0d0c64d2e8a1e7d1457df2e5a3c51c73235be")
        let keyChain3 = BTCKeychain(seed: seed3.hexStringData())
        XCTAssertEqual(keyChain3.extendedPrivateKey?.base58, "xprv9s21ZrQH143K25QhxbucbDDuQ4naNntJRi4KUfWT7xo4EKsHt2QJDu7KXp1A3u7Bi1j8ph3EGsZ9Xvz9dGuVrtHHs7pXeTzjuxBrCmmhgC6")
        XCTAssertEqual(keyChain3.extendedPublicKey.base58, "xpub661MyMwAqRbcEZVB4dScxMAdx6d4nFc9nvyvH3v4gJL378CSRZiYmhRoP7mBy6gSPSCYk6SzXPTf3ND1cZAceL7SfJ1Z3GC8vBgp2epUt13")
        let path3 = "m/0'"
        let W3_m_0H = keyChain3.derivedKeychain(withPath: path3)
        XCTAssertEqual(W3_m_0H?.extendedPrivateKey?.base58, "xprv9uPDJpEQgRQfDcW7BkF7eTya6RPxXeJCqCJGHuCJ4GiRVLzkTXBAJMu2qaMWPrS7AANYqdq6vcBcBUdJCVVFceUvJFjaPdGZ2y9WACViL4L")
        XCTAssertEqual(W3_m_0H?.extendedPublicKey.base58, "xpub68NZiKmJWnxxS6aaHmn81bvJeTESw724CRDs6HbuccFQN9Ku14VQrADWgqbhhTHBaohPX4CjNLf9fq9MYo6oDaPPLPxSb7gwQN3ih19Zm4Y")
    }
    
    func testKeysFromKeychain() {
        let seed = String("87eaaac5a539ab028df44d9110defbef3797ddb805ca309f61a69ff96dbaa7ab5b24038cf029edec5235d933110f0aea8aeecf939ed14fc20730bba71e4b1110").hexStringData()
        let keychain = BTCKeychain(seed: seed)
        let coinType = keychain.network.coinType
        let derived47 = keychain.derivedKeychain(withPath: "m/47'/\(coinType)'/0'/0")
        XCTAssertEqual(derived47?.extendedPrivateKey?.privateKey.hexString(), "04448fd1be0c9c13a5ca0b530e464b619dc091b299b98c5cab9978b32b4a1b8b")
        XCTAssertEqual(derived47?.extendedPublicKey.publicKey.hexString(), "024ce8e3b04ea205ff49f529950616c3db615b1e37753858cc60c1ce64d17e2ad8")
        XCTAssertEqual(derived47?.address, "1ChvUUvht2hUQufHBXF8NgLhW8SwE2ecGV")
    }
    
    func testKeychain47() {
        let seed = String("64dca76abc9c6f0cf3d212d248c380c4622c8f93b2c425ec6a5567fd5db57e10d3e6f94a2f6af4ac2edb8998072aad92098db73558c323777abf5bd1082d970a").hexStringData()
        let keychain = BTCKeychain(seed: seed)
        let coinType = keychain.network.coinType
        let kc47 = keychain.derivedKeychain(withPath: "m/47'/\(coinType)'/0'", andType: .BIP47)
        let kc47FirstKey = kc47?.derivedKeychain(withPath: "0")
        XCTAssertEqual(kc47FirstKey?.extendedPrivateKey?.privateKey.hexString(), "8d6a8ecd8ee5e0042ad0cb56e3a971c760b5145c3917a8e7beaf0ed92d7a520c")
        XCTAssertEqual(kc47FirstKey?.extendedPublicKey.publicKey.hexString(), "0353883a146a23f988e0f381a9507cbdb3e3130cd81b3ce26daf2af088724ce683")
    }
    
    // https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki#test-vectors
    func testBIP49testnet() { 
        let seed = Mnemonic.createSeed(mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about")
        let keychain = BTCKeychain(seed: seed, network: .test)
        let coinType = keychain.network.coinType
        let kc49 = keychain.derivedKeychain(withPath: "m/49'/\(coinType)'/0'", andType: .BIP49)
        let recvKey0 = kc49?.recieveKeychain(atIndex: 0, withType: .BIP49)
        
        XCTAssertEqual(recvKey0?.address, "2Mww8dCYPUpKHofjgcXcBCEGmniw9CoaiD2")
    }

    // https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#test-vectors
    func testKeychain84() {
        let seed = String("5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4").hexStringData()
        let keychain = BTCKeychain(seed: seed)
        let coinType = keychain.network.coinType
        let kc84 = keychain.derivedKeychain(withPath: "m/84'/\(coinType)'/0'", andType: .BIP84)
        let recvKey0 = kc84?.recieveKeychain(atIndex: 0, withType: .BIP84)
        let recvKey1 = kc84?.recieveKeychain(atIndex: 1, withType: .BIP84)
        let changeKey0 = kc84?.changeKeychain(atIndex: 0, withType: .BIP84)
        XCTAssertEqual(recvKey0?.address, "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu")
        XCTAssertEqual(recvKey1?.address, "bc1qnjg0jd8228aq7egyzacy8cys3knf9xvrerkf9g")
        XCTAssertEqual(changeKey0?.address, "bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el")
    }

}
