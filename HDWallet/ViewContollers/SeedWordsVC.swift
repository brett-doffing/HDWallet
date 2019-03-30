// SeedWordsVC.swift

import UIKit

class SeedWordsVC: UIViewController, UITextFieldDelegate {
    let userDefaults = UserDefaults.standard
    var seedWords: [String]?
    @IBOutlet weak var txtfld1: UITextField!
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
        if let words = self.seedWords {
            for i in 0..<words.count {
                let textField = self.view.viewWithTag(i+1) as! UITextField
                textField.text = words[i]
            }
        } else {
            // Delegation set in IB
            self.txtfld1?.becomeFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        if tag <= 11 {
            let nextTag = tag + 1
            // Try to find next textField
            let nextResponder = self.view.viewWithTag(nextTag) as! UITextField
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            verifySeedWordCompletion()
        }
        return false
    }
    
    func verifySeedWordCompletion() {
        // Ideally check for correctness as well
        if txtfld1.text != nil &&
            txtfld2.text != nil &&
            txtfld3.text != nil &&
            txtfld4.text != nil &&
            txtfld5.text != nil &&
            txtfld6.text != nil &&
            txtfld7.text != nil &&
            txtfld8.text != nil &&
            txtfld9.text != nil &&
            txtfld10.text != nil &&
            txtfld11.text != nil &&
            txtfld12.text != nil
        {
            // Save and dismiss
            let seedWords: [String] = [txtfld1.text!, txtfld2.text!, txtfld3.text!, txtfld4.text!, txtfld5.text!, txtfld6.text!, txtfld7.text!, txtfld8.text!, txtfld9.text!, txtfld10.text!, txtfld11.text!, txtfld12.text!]
            userDefaults.set(seedWords, forKey: "seedWords")
        } else {
            // Alert
        }
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        return true
//    }
}
