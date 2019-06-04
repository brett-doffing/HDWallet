// SendVC.swift

import UIKit
import AVFoundation
import CoreData

class SendVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var qrScanner: QRScanningView?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addressTxtFld: UITextField!
    @IBOutlet weak var btcTxtFld: UITextField!
    var recipients: [[String]] = []
    let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.tableView.backgroundColor = .clear
        NotificationCenter.default.addObserver(self, selector: #selector(qrCodeScannedNotification(_:)), name: .scannedQRCode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(txPostedNotification(_:)), name: .transactionPosted, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.qrScanner != nil {
            self.qrScanner?.removeFromSuperview()
            self.qrScanner = nil
        }
    }
    
    @IBAction func showQRView(_ sender: UIButton) {
        self.qrScanner = QRScanningView(frame: view.bounds)
        view.addSubview(self.qrScanner!)
        self.qrScanner?.beginScanning()
    }
    
    @IBAction func addRecipient(_ sender: UIButton) {
        if self.addressTxtFld.text != "" && self.btcTxtFld.text != "" {
            let recipient: [String] = [self.addressTxtFld!.text!, self.btcTxtFld!.text!]
            self.recipients.append(recipient)
            let section0 = IndexSet.init(integer: 0)
            self.tableView.reloadSections(section0, with: .fade)
            self.addressTxtFld.resignFirstResponder()
            self.btcTxtFld.resignFirstResponder()
            self.addressTxtFld.text = ""
            self.btcTxtFld.text = ""
        }
    }
    
    @IBAction func sendTransaction(_ sender: UIButton) {
        if self.recipients.count > 0 {
            var satoshis = 0
            for recipient in self.recipients {
                let sats = recipient[1]
                satoshis += Int(sats)!
            }
            self.beginTX(withNumberOfSatoshis: satoshis)
        }
    }
    
    @objc func qrCodeScannedNotification(_ notification:Notification) {
        if let userInfo = notification.userInfo as? [String : String], let qrString = userInfo["qrString"] {
            self.addressTxtFld.text = qrString
        }
        UIView.animateKeyframes(withDuration: 0.1, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(3)
            self.qrScanner?.qrCodeFrameView?.alpha = 0
        }) { (complete) in
            UIView.animate(withDuration: 0.5, animations: {
                self.qrScanner?.frame.origin.y = 1000
            }, completion: { (complete) in
                self.qrScanner?.removeFromSuperview()
                self.qrScanner = nil
            })
        }
    }
    
    @objc func txPostedNotification(_ notification:Notification) {
        self.tabBarController?.selectedIndex = 0
    }
    
    deinit {
        print("deinitializing Send VC")
    }
}

extension SendVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            return
        default:
            return
        }
    }
}

extension SendVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recipients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        let recipient = self.recipients[indexPath.row]
        let address = recipient[0]
        let satoshis = recipient[1]
        cell.textLabel?.text = "₿ \(Double(satoshis)!/100000000)"
        cell.detailTextLabel?.text = "\(address)"
        return cell
    }
}

extension SendVC {
    private func beginTX(withNumberOfSatoshis satoshis: Int) {
        self.getOutputs(forSatoshis: satoshis)
    }
    
    private func getOutputs(forSatoshis satoshis: Int) {
        var addresses: [Address] = []
        var outputs: [Vout] = []
        var possibleUTXOs: [Vout] = []
        do {
            addresses = try AppDelegate.viewContext.fetch(Address.fetchRequest())
            
            let predicate = NSPredicate(format:"scriptPubKey_address IN %@", addresses.map{$0.str})
            let fetchOutputs: NSFetchRequest<Vout> = Vout.fetchRequest()
            fetchOutputs.predicate = predicate
            outputs = try AppDelegate.viewContext.fetch(fetchOutputs)
            
            var totalSats = 0
            for output in outputs {
                possibleUTXOs.append(output)
                let sats = output.value * Double(100000000)
                totalSats += Int(sats)
                if totalSats > satoshis { break }
            }
            self.createRawTX(withOutputs: possibleUTXOs)
        } catch {
            print(error)
        }
    }
    
    private func createRawTX(withOutputs outputs: [Vout]) {
        var utxos: [TxOutput] = []
//        var walletIndicies: [Int32] = []
        for output in outputs {
            let utxo = TxOutput()
            utxo.address = output.scriptPubKey_address!
            utxo.n = UInt32(output.n)
            utxo.satoshis = UInt64(output.value * Double(100000000))
            utxo.script = output.scriptPubKey?.hexStringData()
            utxo.txid = output.transaction?.id?.unhexlify().bigToLittleEndian().data
            utxos.append(utxo)
//            let index = output.walletAddress?.walletIndex
//            walletIndicies.append(index!)
        }
        
        var receivingAddresses: [String] = []
        var satoshisArray: [UInt64] = []
        var scriptSigs: [Data] = []
        for recipient in self.recipients {
            receivingAddresses.append(recipient[0])
            satoshisArray.append(UInt64(recipient[1])!)
        }
        var newRawTx = BTCTransaction.shared.createTX(scriptSigs: scriptSigs, satoshis: satoshisArray, receivingAddresses: receivingAddresses, utxos: utxos)
        newRawTx += UInt32(0x00000001).littleEndian
        var doubleSha256 = newRawTx.doubleSHA256().bytes
        
        guard let mnemonic = try? self.kcpi.readPassword() else { return }
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let masterKC = BTCKeychain(seed: seed, network: .test)
        let kc44 = masterKC.derivedKeychain(withPath: "m/44'/1'/0'/0/0", andType: .BIP44) // FIXME: testnet only, allow for variable index
        var privateKey = kc44?.extendedPrivateKey?.privateKey.bytes
        
//        var privateKeys: [[UInt8]] = []
//        for index in walletIndicies { // FIXME: Account for indicies when adding addresses to database
//            let kc44 = masterKC.derivedKeychain(withPath: "m/44'/1'/0'/0/0", andType: .BIP44) // FIXME: testnet only, allow for variable index
////            print("pubKey = \(kc44?.extendedPublicKey.publicKey.base58CheckEncodedString)")
//            let prvkey = kc44?.extendedPrivateKey?.privateKey.bytes
//            privateKeys.append(prvkey!)
////            let pubkey = try? BTCCurve.shared.generatePublicKey(privateKey: prvkey!)
////            print("second pubkey = \(pubkey!.base58CheckEncodedString)")
//        }
        
        for utxo in utxos {
            let signature: secp256k1_ecdsa_signature = try! BTCCurve.shared.sign(key: privateKey!, message: doubleSha256)
            let publicKey = try! BTCCurve.shared.generatePublicKey(privateKey: privateKey!.data)
            var encodedSig = try! BTCCurve.shared.encodeDER(signature: signature)
            encodedSig = BTCCurve.shared.appendDERbytes(encodedDERSig: encodedSig, hashType: 0x01, scriptPubKey: utxo.script!.bytes, pubkey: publicKey.bytes)
            scriptSigs.append(encodedSig.data)
            newRawTx = BTCTransaction.shared.createTX(scriptSigs: scriptSigs, satoshis: satoshisArray, receivingAddresses: receivingAddresses, utxos: utxos)
            // FIXME: need to add doublehashing for multiple outputs
        }
        print("rawtx = \(newRawTx.hexString())")
        BlockstreamService.shared.postRawTransaction(rawTX: newRawTx.hexString())
    }
}
