// SettingsVC.swift

import UIKit

class SettingsVC: UIViewController {
    
    let defaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func switchChanged(_ sender : UISwitch){
        let testnetSwitch = sender
        if self.tabBarController?.tabBar.isHidden == true {
            self.tabBarController?.tabBar.isHidden = false
            self.defaults.set(testnetSwitch.isOn, forKey: "testnet")
        } else {
            let alert = UIAlertController(title: "Changing Networks", message: "You will need to quit the app and close it out completely for network changes to take effect. Would you like to continue changing the nework?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                testnetSwitch.isOn ? testnetSwitch.setOn(false, animated: true) : testnetSwitch.setOn(true, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { [weak self] (action) in
                self?.tabBarController?.tabBar.isHidden = true
                self?.defaults.set(testnetSwitch.isOn, forKey: "testnet")
            }))
            self.present(alert, animated: true)
        }
    }
}

extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            return
        default:
            break
        }
    }
}

extension SettingsVC: UITableViewDataSource {
    
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
            cell.textLabel?.text = "Testnet"
            cell.textLabel?.textColor = .white
            let testnetSwitch = UISwitch(frame: .zero)
            testnetSwitch.tintColor = #colorLiteral(red: 0.9693624377, green: 0.5771938562, blue: 0.1013594046, alpha: 1)
            let isTestnet = defaults.bool(forKey: "testnet")
            testnetSwitch.setOn(isTestnet, animated: true)
            testnetSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = testnetSwitch
        default:
            break
        }
        cell.backgroundColor = .clear
        return cell
    }
    
}
