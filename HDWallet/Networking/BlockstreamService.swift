// BlockstreamService.swift

import UIKit

enum RequestType: String {
    case transaction = "tx/"
}

class BlockstreamService {
    static let shared = BlockstreamService()
    
    let baseURL: String = "https://blockstream.info/testnet/api/"
    let defaults = UserDefaults.standard
    let isTestnet: Bool = UserDefaults.standard.bool(forKey: "testnet")
    
    private init() {
        
    }
    
    func getTransaction(withTXID txid: String) {
        let urlString = baseURL + "tx/" + txid
        guard let url = URL(string: urlString) else { return }
//        getRequest(withURL: url) { (response, error) in
//            completionHandler(response, error)
//        }
    }
    
    func getTransactions(forAddress address: String, completionHandler: @escaping (Any?, Error?) -> ()) {
        let urlString = baseURL + "address/" + address + "/txs"
        guard let url = URL(string: urlString) else { return }
        getRequest(withURL: url) { (response, error) in
            completionHandler(response, error)
        }
    }
    
    private func getRequest(withURL url: URL, completionHandler: @escaping (Any?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil { completionHandler(nil, error) }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with:data, options: .allowFragments)
                
                //Get back to the main queue?
                DispatchQueue.main.async { completionHandler(jsonResponse, nil) }
            } catch let jsonError { completionHandler(nil, jsonError) }
        }.resume()
    }
}
