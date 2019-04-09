// ReceiveVC.swift

import UIKit
import LocalAuthentication

class ReceiveVC: UIViewController {
    
    var hasSeed: Bool = false
    let defaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var qrImageView: QRImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copiedLabel: UILabel!
    
    var p2pkhAddr = String()
    var p2shAddr = String()
    var bech32Addr = String()
    var payCode = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Comment out to keep keychain data.
//        deleteBTCKeychainData()
        
        let copyLabelTap = UITapGestureRecognizer(target: self, action: #selector(copyAddressToClipboard))
        self.addressLabel.addGestureRecognizer(copyLabelTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForSeed()
        if !self.hasSeed { alertToCreateKeychain() }
        else if self.addressLabel.text == "" {
            getKeychainAddresses()
            self.tableView.reloadData()
            self.qrImageView.qrString = self.p2pkhAddr
            self.addressLabel.text = self.p2pkhAddr
            self.qrImageView.createQRCImage()
        }
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
        catch let kcError { print("error = \(kcError)"); return } // TODO: Handle
        
        // Save current addresses to defaults
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let masterKC = BTCKeychain(seed: seed)
        let kc44 = masterKC.derivedKeychain(withPath: "m/44'/0'/0'/0/0", andType: .BIP44)
        let kc47 = masterKC.derivedKeychain(withPath: "m/47'/0'/0'", andType: .BIP47)
        let kc49 = masterKC.derivedKeychain(withPath: "m/49'/0'/0'/0/0", andType: .BIP49)
        let kc84 = masterKC.derivedKeychain(withPath: "m/84'/0'/0'/0/0", andType: .BIP84)
        let payCode = BIP47.shared.paymentCode(forBIP47Keychain: kc47!)
        defaults.setValue(kc44?.address, forKey: "currentP2PKHAddress")
        defaults.setValue(kc49?.address, forKey: "currentP2SHAddress")
        defaults.setValue(kc84?.address, forKey: "currentBECH32Address")
        defaults.setValue(payCode, forKey: "paymentCode")
        self.p2pkhAddr = kc44!.address
        self.p2shAddr = kc49!.address
        self.bech32Addr = kc84!.address
        self.payCode = payCode
    }
    
    private func showSeedWordsVC() {
        DispatchQueue.main.async { [weak self] in
            let seedwordsVC = SeedWordsVC()
            self?.navigationController?.pushViewController(seedwordsVC, animated: true)
        }
    }
    
    private func getKeychainAddresses() {
        self.p2pkhAddr = defaults.value(forKey: "currentP2PKHAddress") as! String
        self.p2shAddr = defaults.value(forKey: "currentP2SHAddress") as! String
        self.bech32Addr = defaults.value(forKey: "currentBECH32Address") as! String
        self.payCode = defaults.value(forKey: "paymentCode") as! String
    }
    
    @objc func copyAddressToClipboard() {
        UIPasteboard.general.string = self.addressLabel.text
        self.copiedLabel.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            self?.copiedLabel.alpha = 0
        }
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "P2PKH"
        case 1:
            cell.textLabel?.text = "Segwit (P2SH)"
        case 2:
            cell.textLabel?.text = "Segwit (Bech 32)"
        case 3:
            cell.textLabel?.text = "Payment Code"
        default:
            return cell
        }
        return cell
    }
    
}

extension ReceiveVC {
    func deleteBTCKeychainData() {
        let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
        try? kcpi.deleteItem()
        defaults.setValue(nil, forKey: "currentP2PKHAddress")
        defaults.setValue(nil, forKey: "currentP2SHAddress")
        defaults.setValue(nil, forKey: "currentBECH32Address")
        defaults.setValue(nil, forKey: "paymentCode")
    }
}
