//
//  HomeVC.swift
//  HDWallet
//

import UIKit
import secp256k1
import CommonCrypto

class HomeVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
//        let restAPI = BlockstreamService()
//        restAPI.getTransaction(withTXID: "7d3b53b00d59f53b1cf2cd7fc27777688b0f335c6fb6cdad2871b76a4b81bbc8")
//        restAPI.getTransactions(forAddress: "1CPXCnCha7yDU5W23mt8qQLkV2kFBRJggJ")
        
    }
 
    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Wallet \(indexPath.row + 1)"
        cell.detailTextLabel?.text = "Path = m/'0/'0/0/1"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Wallets"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Wallet paths append /0 and /1."
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCreatWalletVC" {
            let cancelItem = UIBarButtonItem()
            cancelItem.title = "Cancel"
            navigationItem.backBarButtonItem = cancelItem // This will show in the next view controller being pushed
        }
    }
}
