// ReceiveVC.swift

import UIKit
import LocalAuthentication

class ReceiveVC: UIViewController {
    
    var hasSeed: Bool = false
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var qrImageView: QRImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    // Temp properties to be replaced by data store
    var p2pkhAddr: String?
    var p2shAddr: String?
    var bech32Addr: String?
    var payCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Comment out to save seed words, otherwise this sets the saved seed words to nil.
//        let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
//        try? kcpi.deleteItem()
        
        checkForSeed()
        
        // Temp
        if self.hasSeed { getKeychainAddresses() }
        self.qrImageView.qrString = self.p2pkhAddr
        self.addressLabel.text = self.p2pkhAddr
        self.qrImageView.createQRCImage()
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
    
    // MARK: Temp function to be replaced by data store
    private func getKeychainAddresses() {
        let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
        guard let mnemonic = try? kcpi.readPassword() else { return }
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let masterKC = BTCKeychain(seed: seed)
        let kc44 = masterKC.derivedKeychain(withPath: "m/44'/0'/0'/0/0", andType: .BIP44)
        let kc47 = masterKC.derivedKeychain(withPath: "m/47'/0'/0'", andType: .BIP47)
        let kc49 = masterKC.derivedKeychain(withPath: "m/49'/0'/0'/0/0", andType: .BIP49)
        let kc84 = masterKC.derivedKeychain(withPath: "m/84'/0'/0'/0/0", andType: .BIP84)
        self.p2pkhAddr = kc44?.address
        self.p2shAddr = kc49?.address
        self.bech32Addr = kc84?.address
        self.payCode = BIP47.shared.paymentCode(forBIP47Keychain: kc47!)
    }
}

extension ReceiveVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.qrImageView.qrString = self.p2pkhAddr
            self.addressLabel.text = self.p2pkhAddr
        case 1:
            self.qrImageView.qrString = self.p2shAddr
            self.addressLabel.text = self.p2shAddr
        case 2:
            self.qrImageView.qrString = self.bech32Addr
            self.addressLabel.text = self.bech32Addr
        case 3:
            self.qrImageView.qrString = self.payCode
            self.addressLabel.text = self.payCode
        default:
            return
        }
        self.qrImageView.createQRCImage()
    }
}

extension ReceiveVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.lineBreakMode = .byTruncatingMiddle
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "\(self.p2pkhAddr!)"
            cell.detailTextLabel?.text = "P2PKH"
        case 1:
            cell.textLabel?.text = "\(self.p2shAddr!)"
            cell.detailTextLabel?.text = "Segwit (P2SH)"
        case 2:
            cell.textLabel?.text = "\(self.bech32Addr!)"
            cell.detailTextLabel?.text = "Segwit (Bech 32)"
        case 3:
            cell.textLabel?.text = "\(self.payCode!)"
            cell.detailTextLabel?.text = "Payment Code"
        default:
            return cell
        }
        cell.accessoryView = UIImageView(image: UIImage(named: "copyIcon"))
        cell.accessoryView?.tintColor = .black
        return cell
    }
    
}
