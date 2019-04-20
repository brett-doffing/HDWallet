// SidePanelVC.swift

import UIKit

class LeftSidePanelVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    weak var rootContainerVC: RootContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}


extension LeftSidePanelVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(UIApplication.shared.keyWindow?.rootViewController?.value(forKey: "_printHierarchy"))
        guard let rootNav = self.rootContainerVC?.rootNavigationController else { return }
        switch indexPath.row {
        case 0:
            rootNav.viewControllers = [TabBarVC()]
            return
        case 1:
            rootNav.viewControllers = [TestVC()]
            return
        default:
            return
        }
    }
}

extension LeftSidePanelVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        cell.textLabel?.font = UIFont.bitcoinFontWith(size: 17)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Main"
        case 1:
            cell.textLabel?.text = "Test"
        default:
            return cell
        }
        return cell
    }
    
    deinit {
        print("deinitializing Side Panel VC")
    }
}
