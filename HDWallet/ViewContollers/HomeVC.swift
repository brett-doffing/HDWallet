// HomeVC.swift

import UIKit
import LocalAuthentication

class HomeVC: UIViewController {
    
    var hasSeed: Bool = false
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Comment out to save seed words, otherwise this sets the saved seed words to nil.
        let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
        try? kcpi.deleteItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
        guard let _ = try? kcpi.readPassword() else {
            let alert = UIAlertController(title: "You have not created a wallet.", message: "Would you like to randomly create one, or create one from seed words?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Randomly Generate", style: .default, handler: { [weak self] action in
                let authContext: LAContext = LAContext()
                var policy: LAPolicy
                if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                    policy = .deviceOwnerAuthenticationWithBiometrics
                } else {
                    policy = .deviceOwnerAuthentication
                }
                self?.autenticateDeviceOwner(withPolicy: policy, andContext: authContext)
            }))
            alert.addAction(UIAlertAction(title: "Enter Seed Words", style: .default, handler: { [weak self] action in
                self?.showSeedWordsVC()
            }))
            self.present(alert, animated: true)
            return
        }
    }
    
    private func randomlyGenerateMaster() -> [String] {
        let mnemonic = Mnemonic.create().components(separatedBy: " ")
        return mnemonic
    }
    
    private func autenticateDeviceOwner(withPolicy policy: LAPolicy, andContext authContext: LAContext) {
        authContext.evaluatePolicy(policy, localizedReason: "Authenticate user to save randomly generated seed.", reply: { [weak self] (wasAuthenticated, error) in
            if wasAuthenticated {
                let mnemonic = Mnemonic.create()
                let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
                do { try kcpi.savePassword(mnemonic) }
                catch let kcError { print("error = \(kcError)") }
                self?.showSeedWordsVC()
            } else {/* TODO: handle */}
        })
    }
    
    private func showSeedWordsVC() {
        DispatchQueue.main.async { [weak self] in
            let seedwordsVC = SeedWordsVC()
            self?.navigationController?.pushViewController(seedwordsVC, animated: true)
        }
    }
}
