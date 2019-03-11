// BlockstreamService.swift

import UIKit

enum RequestType: String {
    case transaction = "tx/"
}

class BlockstreamService {
    let baseURL: String = "https://blockstream.info/api/"
    
    func getTransaction(withTXID txid: String) {
        let urlString = baseURL + "tx/" + txid
        guard let url = URL(string: urlString) else { return }
        getRequest(withURL: url)
    }
    
    func getTransactions(forAddress address: String) {
        let urlString = baseURL + "address/" + address + "/txs"
        guard let url = URL(string: urlString) else { return }
        getRequest(withURL: url)
    }
    
    private func getRequest(withURL url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil { print(error!.localizedDescription) }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with:data, options: .allowFragments)
                
                //Get back to the main queue
                DispatchQueue.main.async { print(jsonResponse) }
            } catch let jsonError { print(jsonError) }
        }.resume()
    }
}
