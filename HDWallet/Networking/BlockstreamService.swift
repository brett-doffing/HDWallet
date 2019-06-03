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
    
    func getTransaction(withTXID txid: String, completionHandler: @escaping (BlockstreamResponseObject?, Error?) -> ()) {
        let urlString = baseURL + "tx/" + txid
        guard let url = URL(string: urlString) else { return }
        getRequest(withURL: url) { [weak self] (responseData, error) in
            if responseData != nil {
                let bro = self?.getBRO(forResponseObject: responseData!)
                completionHandler(bro, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    func getTransactions(forAddress address: String, completionHandler: @escaping (BlockstreamResponseObject?, Error?) -> ()) {
        let urlString = baseURL + "address/" + address + "/txs"
        guard let url = URL(string: urlString) else { return }
        getRequest(withURL: url) { [weak self] (responseData, error) in
            if responseData != nil {
                let bro = self?.getBRO(forResponseObject: responseData!)
                completionHandler(bro, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    private func getRequest(withURL url: URL, completionHandler: @escaping ([String:Any?]?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil { completionHandler(nil, error) }
            guard let data = data else { completionHandler(nil, error); return }
            do {
                let jsonWithRootArray = try JSONSerialization.jsonObject(with:data, options: [.allowFragments]) as! [[String:Any?]]
//                print(jsonWithRootArray.first)
                completionHandler(jsonWithRootArray.first, nil)
            } catch let jsonError {
                completionHandler(nil, jsonError)
            }
            }.resume()
    }
    
    private func getBRO(forResponseObject response: [String:Any?]) -> BlockstreamResponseObject {
        let bro = BlockstreamResponseObject()
        for (key, value) in response {
            switch key {
            case "txid":
                if let txid = value as? String {bro.txid = txid}
            case "size":
                if let size = value as? Int {bro.size = size}
            case "locktime":
                if let locktime = value as? Int {bro.locktime = locktime}
            case "weight":
                if let weight = value as? Int {bro.weight = weight}
            case "version":
                if let version = value as? Int {bro.version = version}
            case "fee":
                if let fee = value as? Int {bro.fee = fee}
            case "status":
                if let status = value as? [String:Any] {
                    var blockInfo = BlockstreamResponseObject.BlockInfo()
                    if let blockHash = status["block_hash"] as? String {blockInfo.blockHash = blockHash}
                    if let blockTime = status["block_time"] as? Int {blockInfo.blockTime = blockTime}
                    if let blockHeight = status["block_height"] as? Int {blockInfo.blockHeight = blockHeight}
                    if let confirmed = status["confirmed"] as? Bool {blockInfo.confirmed = confirmed}
                    bro.blockInfo = blockInfo
                }
            case "vin":
                if let vinArray = value as? [[String:Any]] {
                    for indexed_vin in vinArray {
                        var vin = BlockstreamResponseObject.V_in()
                        if let isCoinbase = indexed_vin["is_coinbase"] as? Bool {vin.isCoinbase = isCoinbase}
                        if let scriptSig = indexed_vin["scriptsig"] as? String {vin.scriptSig = scriptSig}
                        if let scriptSig_asm = indexed_vin["scriptsig_asm"] as? String {vin.scriptSig_asm = scriptSig_asm}
                        if let sequence = indexed_vin["sequence"] as? Int {vin.sequence = sequence}
                        if let txid = indexed_vin["txid"] as? String {vin.txid = txid}
                        if let vout = indexed_vin["vout"] as? Int {vin.vout = vout}
                        if let witness = indexed_vin["witness"] as? [String] {vin.witness = witness}
                        if let prevout = indexed_vin["prevout"] as? [String:Any] {
                            var previousOutput = BlockstreamResponseObject.V_out()
                            if let scriptPubKey = prevout["scriptpubkey"] as? String {previousOutput.scriptPubKey = scriptPubKey}
                            if let scriptPubKey_asm = prevout["scriptpubkey_asm"] as? String {previousOutput.scriptPubKey_asm = scriptPubKey_asm}
                            if let scriptPubKey_address = prevout["scriptpubkey_address"] as? String {previousOutput.scriptPubKey_address = scriptPubKey_address}
                            if let scriptPubKey_type = prevout["scriptpubkey_type"] as? String {previousOutput.scriptPubKey_type = scriptPubKey_type}
                            if let value = prevout["value"] as? Double {previousOutput.value = value/100000000}
                            vin.prevout = previousOutput
                        }
                        bro.vinArray.append(vin)
                    }
                }
            case "vout":
                if let voutArray = value as? [[String:Any]] {
                    var index = 0
                    for indexed_vout in voutArray {
                        var vout = BlockstreamResponseObject.V_out()
                        if let scriptPubKey = indexed_vout["scriptpubkey"] as? String {vout.scriptPubKey = scriptPubKey}
                        if let scriptPubKey_asm = indexed_vout["scriptpubkey_asm"] as? String {vout.scriptPubKey_asm = scriptPubKey_asm}
                        if let scriptPubKey_address = indexed_vout["scriptpubkey_address"] as? String {vout.scriptPubKey_address = scriptPubKey_address}
                        if let scriptPubKey_type = indexed_vout["scriptpubkey_type"] as? String {vout.scriptPubKey_type = scriptPubKey_type}
                        if let value = indexed_vout["value"] as? Double {vout.value = value/100000000}
                        vout.n = index
                        index += 1
                        bro.voutArray.append(vout)
                    }
                }
            default:
                print("defaulted")
            }
        }
        return bro
    }
}
