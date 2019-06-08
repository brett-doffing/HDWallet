// ReceiveVC.swift

import UIKit
import LocalAuthentication
import CoreData

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
        
        self.setupViews()
        
        let copyLabelTap = UITapGestureRecognizer(target: self, action: #selector(copyAddressToClipboard))
        self.addressLabel.addGestureRecognizer(copyLabelTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        defaults.setValue(nil, forKey: "currentWalletType")
        if !self.hasSeed { alertToCreateKeychain() }
        else if self.addressLabel.text == "" {
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
    
    override func viewWillAppear(_ animated: Bool) {
        checkForSeed()
        if self.hasSeed {
            self.setCurrentAddress()
            // TODO: create a timer to reduce calls
            self.lookupCurrentReceiveAddress()
            
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
    
    private func lookupCurrentReceiveAddress() {
        // TODO: Account for multiple transactions with address.
        self.service.getTransactions(forAddress: self.p2pkhAddr) { (bro, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                DispatchQueue.main.async {
                    guard let responseObject = bro else { return }
                    let address = Address(context: AppDelegate.viewContext)
                    address.isTestnet = self.defaults.bool(forKey: "testnet")
                    // FIXME: Account for mainnet indicies
                    let walletIndex = self.defaults.integer(forKey: "testnetWalletIndex")
                    address.walletIndex = Int32(walletIndex)
                    address.str = self.p2pkhAddr
                    self.defaults.set(walletIndex + 1, forKey: "testnetWalletIndex")
                    self.setCurrentAddress()
                    
                    let tx = Transaction(context: AppDelegate.viewContext)
                    tx.fee = Int64(responseObject.fee!)
                    tx.id = responseObject.txid!
                    tx.locktime = Int64(responseObject.locktime!)
                    tx.size = Int64(responseObject.size!)
                    tx.version = Int64(responseObject.version!)
                    tx.weight = Int64(responseObject.weight!)
                    
                    // FIXME: Need to account for updating the Block when it is not actually in one via being unconfirmed.
                    guard let blockInfo = responseObject.blockInfo else { return }
                    let block = Block(context: AppDelegate.viewContext)
                    block.blockHash = blockInfo.blockHash
                    block.blockHeight = Int64(blockInfo.blockHeight!)
                    block.blockTime = Int64(blockInfo.blockTime!)
                    block.confirmed = blockInfo.confirmed
                    block.transaction = tx
                    
                    for item in responseObject.voutArray {
                        let vout = Vout(context: AppDelegate.viewContext)
                        vout.scriptPubKey = item.scriptPubKey
                        vout.scriptPubKey_asm = item.scriptPubKey_asm
                        vout.scriptPubKey_address = item.scriptPubKey_address
                        if item.scriptPubKey_address == self.p2pkhAddr {
                            vout.walletAddress = address
                        }
                        vout.scriptPubKey_type = item.scriptPubKey_type
                        vout.value = item.value!
                        vout.transaction = tx
                        vout.n = Int64(item.n)
                    }
                    
                    for item in responseObject.vinArray {
                        let vin = Vin(context: AppDelegate.viewContext)
                        vin.scriptSig = item.scriptSig
                        vin.scriptSig_asm = item.scriptSig_asm
                        vin.sequence = Int64(item.sequence!)
                        vin.txid = item.txid
                        vin.vout = Int64(item.vout!)
                        vin.witness = item.witness
                        let prevout = Vout(context: AppDelegate.viewContext)
                        prevout.scriptPubKey = item.prevout?.scriptPubKey
                        prevout.scriptPubKey_asm = item.prevout?.scriptPubKey_asm
                        prevout.scriptPubKey_address = item.prevout?.scriptPubKey_address
                        prevout.scriptPubKey_type = item.prevout?.scriptPubKey_type
                        prevout.value = item.prevout!.value!
                        vin.previousOut = prevout
                        vin.transaction = tx
                    }
                    
                    do {
                        try AppDelegate.viewContext.save()
                    } catch {
                        print(error)
                    }
                    
                    for property in responseObject.properties() {
                        print(property)
                    }
                }
            }
        }
    }
    
    private func setCurrentAddress() { // FIXME: currently testnet only
        let walletIndex = self.defaults.integer(forKey: "testnetWalletIndex")
        let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
        guard let mnemonic = try? kcpi.readPassword() else { return }
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let masterKC = BTCKeychain(seed: seed, network: .test)
        let kc44 = masterKC.derivedKeychain(withPath: "m/44'/1'/0'/0/\(walletIndex)", andType: .BIP44)
        defaults.setValue(kc44?.address, forKey: "testnetP2PKHAddress")
        self.getKeychainAddresses()
        self.qrImageView.qrString = self.p2pkhAddr
        self.addressLabel.text = self.p2pkhAddr
        self.qrImageView.createQRCImage()
    }
    
    private func setupViews() {
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
