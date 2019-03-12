//
//  HDWalletTests.swift
//  HDWalletTests

import XCTest
@testable import HDWallet
@testable import secp256k1

class HDWalletTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // (Key = "Bitcoin seed") as hex
//        let hexKey = "426974636f696e2073656564"
//        let seed = "000102030405060708090a0b0c0d0e0f"
//        let hdMasterKey = HMAC_SHA512.digest(withKey: hexKey, andDataString: seed)
//
//        let key = "Bitcoin seed".data(using: .ascii)
//        let test = HMAC_SHA512.digest(key: key!, data: seed.hexStringData())
//
//        XCTAssertEqual(hdMasterKey, test.hexDescription())
        
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
