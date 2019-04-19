// SidePanelVC.swift

import UIKit

class LeftSidePanelVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


extension LeftSidePanelVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
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
        
        //        switch indexPath.row {
        //        case 0:
        //            cell.textLabel?.text = ""
        //        default:
        //            return cell
        //        }
        cell.backgroundColor = .clear
        return cell
    }
    
}
