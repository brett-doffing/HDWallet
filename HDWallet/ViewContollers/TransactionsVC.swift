// TransactionsVC.swift

import UIKit

class TransactionsVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
}

extension TransactionsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            return
        default:
            return
        }
    }
}

extension TransactionsVC: UITableViewDataSource {
    
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
