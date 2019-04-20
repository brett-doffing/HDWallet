// SeedWordsVC.swift

import UIKit
import LocalAuthentication

class SeedWordsVC: UIViewController, UITextFieldDelegate {
    let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
    var seedWords: [String]?
    @IBOutlet weak var txtfld1: UITextField! // Text Field delegation set in Xib
    @IBOutlet weak var txtfld2: UITextField!
    @IBOutlet weak var txtfld3: UITextField!
    @IBOutlet weak var txtfld4: UITextField!
    @IBOutlet weak var txtfld5: UITextField!
    @IBOutlet weak var txtfld6: UITextField!
    @IBOutlet weak var txtfld7: UITextField!
    @IBOutlet weak var txtfld8: UITextField!
    @IBOutlet weak var txtfld9: UITextField!
    @IBOutlet weak var txtfld10: UITextField!
    @IBOutlet weak var txtfld11: UITextField!
    @IBOutlet weak var txtfld12: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let mnemonic = try? self.kcpi.readPassword() else { DispatchQueue.main.async { self.txtfld1?.becomeFirstResponder() }; return }
        
        authenticateDeviceOwner { (authenticated) in
            if authenticated {
                self.seedWords = mnemonic.components(separatedBy: " ")
                DispatchQueue.main.async { self.displaySeedWords() }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        if tag <= 11 {
            let nextTag = tag + 1
            // Find next textField
            let nextResponder = self.view.viewWithTag(nextTag) as! UITextField
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            verifySeedWordCompletion()
        }
        return false
    }
    
    func verifySeedWordCompletion() {
        guard self.txtfld1.text != nil, self.txtfld2.text != nil, self.txtfld3.text != nil,
            self.txtfld4.text != nil, self.txtfld5.text != nil, self.txtfld6.text != nil,
            self.txtfld7.text != nil, self.txtfld8.text != nil, self.txtfld9.text != nil,
            self.txtfld10.text != nil, self.txtfld11.text != nil, self.txtfld12.text != nil
            else {
                let alert = UIAlertController(title: "Seed Word Error", message: "This word list contains one or more invalid words. Please only use valid words", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
        }
        
        let seedWords: [String] = [self.txtfld1.text!, self.txtfld2.text!, self.txtfld3.text!, self.txtfld4.text!, self.txtfld5.text!, self.txtfld6.text!, self.txtfld7.text!, self.txtfld8.text!, self.txtfld9.text!, self.txtfld10.text!, self.txtfld11.text!, self.txtfld12.text!]
        let englishWords = Set(WordList.english.words)
        guard Set(seedWords).isSubset(of: englishWords) else {
            let alert = UIAlertController(title: "Seed Word Error", message: "This word list contains one or more invalid words. Please only use valid words", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        // Save
        let mnemonic = seedWords.joined(separator: " ")
        do { try self.kcpi.savePassword(mnemonic) }
        catch let kcError { print("error = \(kcError)") } // TODO: Alert
    }
    
    private func authenticateDeviceOwner(authenticated: @escaping (Bool) -> ()) {
        let authContext: LAContext = LAContext()
        var policy: LAPolicy
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        { policy = .deviceOwnerAuthenticationWithBiometrics }
        else
        { policy = .deviceOwnerAuthentication }
        
        authContext.evaluatePolicy(policy, localizedReason: "Authenticate user to view or manage seed.", reply: { (wasAuthenticated, error) in
            authenticated(wasAuthenticated)
        })
    }
    
    private func displaySeedWords() {
        if let words = self.seedWords {
            for i in 0..<words.count {
                let textField = self.view.viewWithTag(i+1) as! UITextField
                textField.text = words[i]
                textField.isUserInteractionEnabled = false
            }
        }
    }
    
    deinit {
        print("deinitializing SeedWords VC")
    }
}
