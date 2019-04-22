// SettingsVC.swift

import UIKit

class SettingsVC: UITableViewController {
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        self.tableView.backgroundColor = .black
        self.tableView.separatorColor = .white
        self.setUpNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    private func setUpNavBar() {
        self.setupHamburgerButton()
        navigationItem.title = "settings"
    }
    
    private func setupHamburgerButton() {
        let hamburgerButton = UIButton(type: .system)
        hamburgerButton.setImage(UIImage(named: "hamburgerIcon"), for: .normal)
        hamburgerButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        hamburgerButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        hamburgerButton.contentMode = .scaleAspectFit
        hamburgerButton.addTarget(self, action: #selector(self.toggleLeftSidePanel), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerButton)
    }
    
    @objc func toggleLeftSidePanel() {
        NotificationCenter.default.post(name: .toggleLeftSidePanel, object: nil)
    }
    
    @objc func switchChanged(_ sender : UISwitch){
        let testnetSwitch = sender
        if self.navigationItem.leftBarButtonItem == nil {
            self.defaults.set(testnetSwitch.isOn, forKey: "testnet")
            self.setupHamburgerButton()
        } else {
            let alert = UIAlertController(title: "Changing Networks", message: "You will need to quit the app and close it out completely for network changes to take effect. Would you like to continue changing the network?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                testnetSwitch.isOn ? testnetSwitch.setOn(false, animated: true) : testnetSwitch.setOn(true, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { [weak self] (action) in
                self?.defaults.set(testnetSwitch.isOn, forKey: "testnet")
                self?.navigationItem.leftBarButtonItem = nil
            }))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            return
        case 1:
            let seedwordsVC = SeedWordsVC()
            self.navigationController?.pushViewController(seedwordsVC, animated: true)
        default:
            break
        }
    }
    
    // MARK: Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Testnet"
            let testnetSwitch = UISwitch(frame: .zero)
            testnetSwitch.tintColor = #colorLiteral(red: 0.9693624377, green: 0.5771938562, blue: 0.1013594046, alpha: 1)
            let isTestnet = defaults.bool(forKey: "testnet")
            testnetSwitch.setOn(isTestnet, animated: true)
            testnetSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = testnetSwitch
        case 1:
            cell.textLabel?.text = "Mnemonic"
        default:
            break
        }
        cell.textLabel?.font = UIFont.bitcoinFontWith(size: 17)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        return cell
    }
    
    deinit {
        print("deinitializing Settings VC")
    }
}
