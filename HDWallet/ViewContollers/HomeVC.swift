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
        
        addNavBarImage()
        checkForSeed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForSeed()
        if !self.hasSeed { alertToCreateKeychain() }
    }
    
    private func checkForSeed() {
        let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
        guard let _ = try? kcpi.readPassword() else { return }
        self.hasSeed = true
    }
    
    private func alertToCreateKeychain() {
        let alert = UIAlertController(title: "You have not created a wallet.", message: "Would you like to randomly create one, or create one from seed words?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Randomly Generate", style: .default, handler: { [weak self] action in
            self?.randomlyGenerateSeed()
            self?.showSeedWordsVC()
        }))
        alert.addAction(UIAlertAction(title: "Enter Seed Words", style: .default, handler: { [weak self] action in
            self?.showSeedWordsVC()
        }))
        self.present(alert, animated: true)
    }
    
    private func randomlyGenerateSeed() {
        let mnemonic = Mnemonic.create()
        let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
        do { try kcpi.savePassword(mnemonic) }
        catch let kcError { print("error = \(kcError)") } // TODO: Handle
    }
    
    private func showSeedWordsVC() {
        DispatchQueue.main.async { [weak self] in
            let seedwordsVC = SeedWordsVC()
            self?.navigationController?.pushViewController(seedwordsVC, animated: true)
        }
    }
    
    private func addNavBarImage() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 153, height: 32))
        let image = UIImage(named: "BTCLogo")
        let imageView = UIImageView(image: image)
        // Nav bar height is 44, image height is 32, so -6 offset to center
        imageView.frame = CGRect(x: 0, y: -6, width: 153, height: 32)
        containerView.addSubview(imageView)
        navigationItem.titleView = containerView
    }
}
