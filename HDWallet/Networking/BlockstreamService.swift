// BlockstreamService.swift

import UIKit

class BlockstreamService {
    static let shared = BlockstreamService()
    
    let baseURL: String
    let defaults = UserDefaults.standard
    
    private init() {
        if self.defaults.bool(forKey: "testnet") == true { self.baseURL = "https://blockstream.info/testnet/api/" }
        else { self.baseURL = "https://blockstream.info/api/" }
    }
    
    func getTransaction(withTXID txid: String, completionHandler: @escaping ([String:Any?]?, Error?) -> ()) {
        let urlString = baseURL + "tx/" + txid
        guard let url = URL(string: urlString) else { return }
        getRequest(withURL: url) { (responseData, error) in
            completionHandler(responseData, error)
        }
    }
    
    func getTransactions(forAddress address: String, completionHandler: @escaping ([String:Any?]?, Error?) -> ()) {
        let urlString = baseURL + "address/" + address + "/txs"
        guard let url = URL(string: urlString) else { return }
        getRequest(withURL: url) { (responseData, error) in
            completionHandler(responseData, error)
        }
    }
    
    private func getRequest(withURL url: URL, completionHandler: @escaping ([String:Any?]?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil { completionHandler(nil, error) }
            guard let data = data else { completionHandler(nil, error); return }
            do {
                let jsonWithRootArray = try JSONSerialization.jsonObject(with:data, options: []) as! [[String:Any?]]
                completionHandler(jsonWithRootArray[0], nil)
            } catch let jsonError {
                completionHandler(nil, jsonError)
            }
        }.resume()
    }
}
