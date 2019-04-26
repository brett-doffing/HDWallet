// ReceiveVC.swift

import UIKit
import LocalAuthentication

class ReceiveVC: UIViewController {
    
    var hasSeed: Bool = false
    let defaults = UserDefaults.standard
    let service = BlockstreamService.shared
    var qrImageView = QRImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    var addressLabel = UILabel()
    var copiedLabel = UILabel()
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    var p2pkhAddr = String()
    var p2shAddr = String()
    var bech32Addr = String()
    var payCode = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Comment out to keep keychain data.
//        deleteBTCKeychainData()
        
        self.view.backgroundColor = .white
        
        self.addressLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.addressLabel)
        self.addressLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.addressLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.addressLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
        self.addressLabel.topAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.addressLabel.textColor = .white
        self.addressLabel.backgroundColor = .black
        self.addressLabel.font = UIFont.bitcoinFontWith(size: 17)
        self.addressLabel.textAlignment = .center
        self.addressLabel.text = ""
        self.addressLabel.isUserInteractionEnabled = true
        
        self.qrImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.qrImageView)
        self.qrImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25).isActive = true
        self.qrImageView.bottomAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -25).isActive = true
        self.qrImageView.heightAnchor.constraint(equalTo: self.qrImageView.widthAnchor, multiplier: 1.0, constant: 0).isActive = true // Aspect ratio 1:1
        self.qrImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.copiedLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.copiedLabel)
        self.copiedLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.copiedLabel.widthAnchor.constraint(equalToConstant: 175).isActive = true
        self.copiedLabel.centerYAnchor.constraint(equalTo: self.qrImageView.centerYAnchor).isActive = true
        self.copiedLabel.centerXAnchor.constraint(equalTo: self.qrImageView.centerXAnchor).isActive = true
        self.copiedLabel.alpha = 0
        self.copiedLabel.text = "Copied to Clipboard"
        self.copiedLabel.textColor = .white
        self.copiedLabel.font = UIFont.bitcoinFontWith(size: 17)
        self.copiedLabel.textAlignment = .center
        
        
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.qrImageView.centerYAnchor).isActive = true
        self.activityIndicator.centerXAnchor.constraint(equalTo: self.qrImageView.centerXAnchor).isActive = true
        
        if self.defaults.bool(forKey: "testnet") == true {
            self.copiedLabel.backgroundColor = .green
            self.activityIndicator.color = .green
        } else {
            self.copiedLabel.backgroundColor = #colorLiteral(red: 0.9693624377, green: 0.5771938562, blue: 0.1013594046, alpha: 1)
            self.activityIndicator.color = #colorLiteral(red: 0.9693624377, green: 0.5771938562, blue: 0.1013594046, alpha: 1)
        }
        
        let copyLabelTap = UITapGestureRecognizer(target: self, action: #selector(copyAddressToClipboard))
        self.addressLabel.addGestureRecognizer(copyLabelTap)
        let refreshSwipe = UISwipeGestureRecognizer(target: self, action: #selector(refreshAddresses))
        refreshSwipe.direction = .down
        self.view.addGestureRecognizer(refreshSwipe)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        defaults.setValue(nil, forKey: "currentWalletType")
        checkForSeed()
        if !self.hasSeed { alertToCreateKeychain() }
        else if self.addressLabel.text == "" {
            getKeychainAddresses()
            if let walletType = self.defaults.value(forKey: "currentWalletType") as? String {
                switch walletType {
                case "P2PKH":
                    self.qrImageView.qrString = self.p2pkhAddr
                    self.addressLabel.text = self.p2pkhAddr
                    self.addressLabel.numberOfLines = 1
                case "P2SH":
                    self.qrImageView.qrString = self.p2shAddr
                    self.addressLabel.text = self.p2shAddr
                    self.addressLabel.numberOfLines = 1
                case "Bech32":
                    self.qrImageView.qrString = self.bech32Addr
                    self.addressLabel.text = self.bech32Addr
                    self.addressLabel.numberOfLines = 1
                case "PayNym":
                    self.qrImageView.qrString = self.payCode
                    self.addressLabel.text = self.payCode
                    self.addressLabel.numberOfLines = 3
                default:
                    return
                }
                self.addressLabel.adjustsFontSizeToFitWidth = true
                self.qrImageView.createQRCImage()
            }
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
        defaults.set("P2PKH", forKey: "currentWalletType")
        // FIXME: should default to testnet, but make sure true or set here.
        if defaults.bool(forKey: "testnet") == true {
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
            // FIXME: Bug where app was deleted, keeps the seed, new app installed, consequently with a seed, and there is no address in defaults.
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
        self.service.getTransactions(forAddress: self.p2pkhAddr) { (bro, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                for property in bro!.properties() {
                    print(property)
                }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        self.service.getTransactions(forAddress: self.p2shAddr) { (bro, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                for property in bro!.properties() {
                    print(property)
                }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        self.service.getTransactions(forAddress: self.bech32Addr) { (bro, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                for property in bro!.properties() {
                    print(property)
                }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
        }
    }
    
    deinit {
        print("deinitializing Receive VC")
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
        defaults.setValue(nil, forKey: "currentWalletType")
    }
}
