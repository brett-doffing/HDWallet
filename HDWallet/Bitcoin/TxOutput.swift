// TxOutput.swift

import Foundation

public class TxOutput {
    var n: UInt32?
    var satoshis: UInt64?
    var address: String?
    var txid: Data?
    var script: Data?
    var unspent: Bool?
}
