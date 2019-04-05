// iOSKeychainTests.swift

import XCTest
@testable import HDWallet

class iOSKeychainTests: XCTestCase {
    
    func testPassword() {
        let kcpi = KeychainPasswordItem(service: "HDWallet", account: "test")
        do {
            try kcpi.savePassword("Password123AbC")
        } catch {
            print("error = \(error)")
        }
        
        do {
            let password = try kcpi.readPassword()
            print(password)
        } catch {
            print("error = \(error)")
        }
    }
    
}
