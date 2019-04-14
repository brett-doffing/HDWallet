// ReceiveVC.swift

import UIKit
import LocalAuthentication

class ReceiveVC: UIViewController {
    
    var hasSeed: Bool = false
    let defaults = UserDefaults.standard
    let service = BlockstreamService.shared
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var qrImageView: QRImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copiedLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        let refreshSwipe = UISwipeGestureRecognizer(target: self, action: #selector(refreshAddresses))
        refreshSwipe.direction = .down
        self.view.addGestureRecognizer(refreshSwipe)
        
        if self.defaults.bool(forKey: "testnet") == true {
            self.tableView.separatorColor = .green
            self.copiedLabel.backgroundColor = .green
            self.activityIndicator.color = .green
        } else {
            self.tableView.separatorColor = #colorLiteral(red: 0.9693624377, green: 0.5771938562, blue: 0.1013594046, alpha: 1)
            self.copiedLabel.backgroundColor = #colorLiteral(red: 0.9693624377, green: 0.5771938562, blue: 0.1013594046, alpha: 1)
            self.activityIndicator.color = #colorLiteral(red: 0.9693624377, green: 0.5771938562, blue: 0.1013594046, alpha: 1)
        }
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
            self?.defaults.set(false, forKey: "testnet") // TODO: change default to testnet
            self?.randomlyGenerateSeed()
            self?.showSeedWordsVC()
        }))
        alert.addAction(UIAlertAction(title: "Enter Seed Words", style: .default, handler: { [weak self] action in
            self?.defaults.set(false, forKey: "testnet") // TODO: change default to testnet
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
        let masterKCT = BTCKeychain(seed: seed, network: .test)
        let kcT44 = masterKCT.derivedKeychain(withPath: "m/44'/1'/0'/0/0", andType: .BIP44)
        let kcT47 = masterKCT.derivedKeychain(withPath: "m/47'/1'/0'", andType: .BIP47)
        let kcT49 = masterKCT.derivedKeychain(withPath: "m/49'/1'/0'/0/0", andType: .BIP49)
        let kcT84 = masterKCT.derivedKeychain(withPath: "m/84'/1'/0'/0/0", andType: .BIP84)
        let payCodeT = BIP47.shared.paymentCode(forBIP47Keychain: kcT47!)
        defaults.setValue(kc44?.address, forKey: "currentP2PKHAddress")
        defaults.setValue(kc49?.address, forKey: "currentP2SHAddress")
        defaults.setValue(kc84?.address, forKey: "currentBECH32Address")
        defaults.setValue(payCode, forKey: "paymentCode")
        defaults.setValue(kcT44?.address, forKey: "testnetP2PKHAddress")
        defaults.setValue(kcT49?.address, forKey: "testnetP2SHAddress")
        defaults.setValue(kcT84?.address, forKey: "testnetBECH32Address")
        defaults.setValue(payCodeT, forKey: "testnetPaymentCode")
        if UserDefaults.standard.bool(forKey: "testnet") == true {
            self.p2pkhAddr = kcT44!.address
            self.p2shAddr = kcT49!.address
            self.bech32Addr = kcT84!.address
            self.payCode = payCodeT
        } else {
            self.p2pkhAddr = kc44!.address
            self.p2shAddr = kc49!.address
            self.bech32Addr = kc84!.address
            self.payCode = payCode
        }
        
    }
    
    private func showSeedWordsVC() {
        DispatchQueue.main.async { [weak self] in
            let seedwordsVC = SeedWordsVC()
            self?.navigationController?.pushViewController(seedwordsVC, animated: true)
        }
    }
    
    private func getKeychainAddresses() {
        if UserDefaults.standard.bool(forKey: "testnet") == true {
            self.p2pkhAddr = defaults.value(forKey: "testnetP2PKHAddress") as! String
            self.p2shAddr = defaults.value(forKey: "testnetP2SHAddress") as! String
            self.bech32Addr = defaults.value(forKey: "testnetBECH32Address") as! String
            self.payCode = defaults.value(forKey: "testnetPaymentCode") as! String
        } else {
            self.p2pkhAddr = defaults.value(forKey: "currentP2PKHAddress") as! String
            self.p2shAddr = defaults.value(forKey: "currentP2SHAddress") as! String
            self.bech32Addr = defaults.value(forKey: "currentBECH32Address") as! String
            self.payCode = defaults.value(forKey: "paymentCode") as! String
        }
    }
    
    @objc func copyAddressToClipboard() {
        UIPasteboard.general.string = self.addressLabel.text
        self.copiedLabel.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            self?.copiedLabel.alpha = 0
        }
    }
    
    // Temp func to refresh
    @objc func refreshAddresses() {
        self.activityIndicator.startAnimating()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.service.getTransactions(forAddress: self.p2pkhAddr) { (responseData, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                print(responseData!)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        self.service.getTransactions(forAddress: self.p2shAddr) { (responseData, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                print(responseData!)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        self.service.getTransactions(forAddress: self.bech32Addr) { (responseData, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                print(responseData!)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
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
        defaults.setValue(nil, forKey: "testnetP2PKHAddress")
        defaults.setValue(nil, forKey: "testnetP2SHAddress")
        defaults.setValue(nil, forKey: "testnetBECH32Address")
        defaults.setValue(nil, forKey: "testnetPaymentCode")
        defaults.setValue(nil, forKey: "testnet")
    }
}
