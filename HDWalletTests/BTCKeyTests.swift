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
}
