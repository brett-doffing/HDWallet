// HomeVC.swift

import UIKit

class HomeVC: UIViewController {
    
    var hasSeed: Bool = false
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Comment out to save seed words, otherwise this sets the saved seed words to nil.
        defaults.setValue(nil, forKey: "seedWords")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard (defaults.value(forKey: "seedWords") as? [String]) != nil else {
            let alert = UIAlertController(title: "You have not created a wallet.", message: "Would you like to randomly create one, or create one from seed words?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Randomly Generate", style: .default, handler: { [weak self] action in
                let mnemonic = self?.randomlyGenerateMaster()
                let seedwordsVC = SeedWordsVC()
                seedwordsVC.seedWords = mnemonic
                self?.navigationController?.pushViewController(seedwordsVC, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Enter Seed Words", style: .default, handler: { [weak self] action in
                let seedwordsVC = SeedWordsVC()
                self?.navigationController?.pushViewController(seedwordsVC, animated: true)
            }))
            self.present(alert, animated: true)
            return
        }
    }
    
    private func randomlyGenerateMaster() -> [String] {
        let mnemonic = Mnemonic.create().components(separatedBy: " ")
        return mnemonic
    }
}
