// SidePanelVC.swift

import UIKit

class LeftSidePanelVC: UITableViewController {
    
    weak var rootContainerVC: RootContainerViewController?
    var walletCellExpanded = false
    let walletCellData = ["P2PKH","P2SH (Segwit)","Bech32 (Segwit)","PayNms"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        self.tableView.backgroundColor = .darkGray
        self.tableView.separatorColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(UIApplication.shared.keyWindow?.rootViewController?.value(forKey: "_printHierarchy"))
        guard let rootNav = self.rootContainerVC?.rootNavigationController else { return }
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                rootNav.viewControllers = [TabBarVC()]
            } else if indexPath.row == 1 {
                
            }
        case 3:
            rootNav.viewControllers = [SettingsVC()]
        default:
            return
        }
        NotificationCenter.default.post(name: .toggleLeftSidePanel, object: nil)
    }
    
    // MARK: Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && self.walletCellExpanded == true {
            return 5
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        cell.textLabel?.font = UIFont.bitcoinFontWith(size: 17)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Wallet"
                let walletAccessory = UIButton(frame: CGRect(x: cell.frame.size.width - 100, y: 5, width: 50, height: cell.frame.size.height - 10))
                walletAccessory.setTitle("Type", for: .normal)
                walletAccessory.setTitleColor(.lightGray, for: .normal)
                walletAccessory.addTarget(self, action: #selector(self.expandWallets), for: .touchUpInside)
                cell.addSubview(walletAccessory)
            } else {
                cell.textLabel?.text = self.walletCellData[indexPath.row - 1]
            }
        case 1:
            cell.textLabel?.text = "Watch-Only"
        case 2:
            cell.textLabel?.text = "Nodes"
        case 3:
            cell.textLabel?.text = "Settings"
        default:
            return cell
        }
        return cell
    }
    
    @objc func expandWallets() {
        if self.walletCellExpanded == true {
            self.walletCellExpanded = false
        } else {
            self.walletCellExpanded = true
        }
        let section0 = IndexSet.init(integer: 0)
        tableView.reloadSections(section0, with: .fade)
    }
    
    deinit {
        print("deinitializing Side Panel VC")
    }
}
