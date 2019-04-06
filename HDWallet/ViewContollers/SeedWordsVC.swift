// SeedWordsVC.swift

import UIKit

class SeedWordsVC: UIViewController, UITextFieldDelegate {
    let defaults = UserDefaults.standard
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
        let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
        guard let mnemonic = try? kcpi.readPassword() else {
            self.txtfld1?.becomeFirstResponder()
            return
        }
        
        self.seedWords = mnemonic.components(separatedBy: " ")
        if let words = self.seedWords {
            for i in 0..<words.count {
                let textField = self.view.viewWithTag(i+1) as! UITextField
                textField.text = words[i]
                textField.isUserInteractionEnabled = false
            }
            let alert = UIAlertController(title: "Mnemonic", message: "Please write down these words, in order, and store in a safe place.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
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
        // Save and dismiss
        let kcpi = KeychainPasswordItem(service: "HDWallet", account: "user")
        let mnemonic = seedWords.joined(separator: " ")
        do { try kcpi.savePassword(mnemonic) }
        catch let kcError { print("error = \(kcError)") } // TODO: Alert
        self.navigationController?.popViewController(animated: true)
    }
}
