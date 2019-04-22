// SidePanelVC.swift

import UIKit

class LeftSidePanelVC: UITableViewController {
    weak var rootContainerVC: RootContainerViewController?
    
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
        switch indexPath.row {
        case 0:
            rootNav.viewControllers = [TabBarVC()]
        case 3:
            rootNav.viewControllers = [SettingsVC()]
        default:
            return
        }
        NotificationCenter.default.post(name: .toggleLeftSidePanel, object: nil)
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
        
        cell.textLabel?.font = UIFont.bitcoinFontWith(size: 17)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Wallets"
        case 1:
            cell.textLabel?.text = "Watch-Only"
        case 2:
            cell.textLabel?.text = "Node(s)"
        case 3:
            cell.textLabel?.text = "Settings"
        default:
            return cell
        }
        return cell
    }
    
    deinit {
        print("deinitializing Side Panel VC")
    }
}
