// PathsPageTVC.swift

import UIKit

class PathsPageTVC: UITableViewController {
    
    let pathLabel = UILabel()
    let pathTxtFld = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 2 }
        else if section == 1 { return 2 }
        else { return 1 }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
            cell?.textLabel?.text = "m/0'"
        } else if indexPath.section == 0 && indexPath.row == 1 {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
            cell?.textLabel?.text = "m/44'/0'/0'"
        } else if indexPath.section == 2 {
            // Alert -> Save
//            NotificationCenter.default.post(name: .setPath, object: nil)
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "BIP 32 Path"
                cell.textLabel?.textAlignment = .center
            } else {
                cell.textLabel?.text = "BIP 44 Path"
                cell.textLabel?.textAlignment = .center
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.textAlignment = .center
            } else {
                pathTxtFld.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(pathTxtFld)
                pathTxtFld.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 50).isActive = true
                pathTxtFld.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -50).isActive = true
                pathTxtFld.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
                pathTxtFld.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                pathTxtFld.borderStyle = .roundedRect
            }
        } else {
            cell.contentView.backgroundColor = .black
            cell.textLabel?.text = "COMPLETE"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .white
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Common Paths:" }
        else if section == 1 { return "Custom Path:" }
        else { return "" }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 { return "Look at info for common wallets that use these paths." }
        else if section == 1 { return "Enter a #, add it to the path, and repeat as desired." }
        else { return "" }
    }
}

extension PathsPageTVC: UITextFieldDelegate {
    
}
