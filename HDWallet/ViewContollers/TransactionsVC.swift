// TransactionsVC.swift

import UIKit
import CoreData

class TransactionsVC: UITableViewController {
    var addresses: [Address] = []
    var outputs: [Vout] = []
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            addresses = try AppDelegate.viewContext.fetch(Address.fetchRequest())
            
            let predicate = NSPredicate(format:"scriptPubKey_address IN %@", addresses.map{$0.str})
            let fetchOutputs: NSFetchRequest<Vout> = Vout.fetchRequest()
            fetchOutputs.predicate = predicate
            outputs = try AppDelegate.viewContext.fetch(fetchOutputs)
            
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        
        let output = outputs[indexPath.row]
        cell.textLabel?.text = "₿ \(output.value)"
        cell.detailTextLabel?.text = output.scriptPubKey_address
//        cell.backgroundColor = .clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            return
        default:
            return
        }
    }
    
    deinit {
        print("deinitializing Transactions VC")
    }
}
