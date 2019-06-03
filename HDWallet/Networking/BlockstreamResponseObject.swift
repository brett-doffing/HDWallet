// BlockstreamResponseObject.swift

import Foundation

class BlockstreamResponseObject {
    var txid: String?
    var size: Int?
    var locktime: Int?
    var weight: Int?
    var version: Int?
    var fee: Int?
    var blockInfo: BlockInfo?
    var vinArray: [V_in] = []
    var voutArray: [V_out] = []
    
    struct V_out {
        var scriptPubKey: String?
        var scriptPubKey_asm: String?
        var scriptPubKey_address: String?
        var scriptPubKey_type: String?
        var value: Double?
    }
    struct V_in {
        var isCoinbase: Bool = false
        var prevout: V_out?
        var scriptSig: String?
        var scriptSig_asm: String?
        var sequence: Int?
        var txid: String?
        var vout: Int?
        var witness: [String]?
    }
    struct BlockInfo { // referred to as "status" in json response
        var blockHash: String?
        var blockTime: Int?
        var blockHeight: Int?
        var confirmed: Bool = false
    }
    
    // A method to print properties of a class.
    func properties() -> [[String: Any]] {
        let mirror = Mirror(reflecting: self)
        
        var retValue = [[String:Any]]()
        for (_, attr) in mirror.children.enumerated() {
            if let property_name = attr.label {
                retValue.append([property_name:attr.value])
            }
        }
        return retValue
    }
}
