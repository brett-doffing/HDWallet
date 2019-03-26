// BTCTransaction.swift

import Foundation

public class BTCTransaction {
    
    static let shared = BTCTransaction()
    
    /// Create Raw Transaction
    ///
    /// - Parameters:
    ///   - scriptSigs: An array of signature scripts. Empty at first, then filled as outputs are signed.
    ///   - satoshis: An array of satoshis to be redeemed (not necessarily the total), with indecies corresponding to receiving addresses.
    ///   - receivingAddresses: An array of addresses receiving Bitcoin in this transaction.
    ///   - utxos: An array of TxOutputs used in this transaction.
    /// - Returns: Raw Transaction as Data
    ///
    /// See Also: [StackOverflow Link](https://bitcoin.stackexchange.com/questions/3374/how-to-redeem-a-basic-tx?)
    /**
    Everything is in little-endian format except for ?
    1. Add four-byte version field: 01000000
    2. One-byte varint specifying the number of inputs
    3. 32-byte hash of the transaction from which we want to redeem output
    4. Four-byte field denoting the output index we want to redeem from the transaction with the above hash (output number 2 = output index 1)
    5. Now comes the scriptSig. For the purpose of signing the transaction, this is temporarily filled with the scriptPubKey of the output we want to redeem. First we write a one-byte varint which denotes the length of the scriptSig (0x19 = 25 bytes): 19
    6. Then we write the actual scriptSig (which is the scriptPubKey of the output we want to redeem): PUSHDATA 47 - Size (in Bytes) to push to stack.
    7. Then we write a four-byte field denoting the sequence. This is currently always set to 0xffffffff. If non-zero locktime is used, then at least one input must have a seq number below 0xffffffff
    8. Next comes a one-byte varint containing the number of outputs in our new transaction.
    9. We then write an 8-byte field (64 bit integer) containing the amount we want to redeem from the specified output. Total amount available (1  BTC) in the output minus a fee of 0.001 BTC (0.999 BTC, or 99900000 Satoshis): 605af40500000000
    10. Then we start writing our transaction's output. We start with a one-byte varint denoting the length of the output script (0x19 or 25 bytes): 19
    11. Then the actual output script
    12. Then we write the four-byte "lock time" field: 00000000. nLockTime, can be either UNIX time or Block Height depending on usage. Before this time, the transaction cannot be accepted into a block.
    */
    public func createTX(scriptSigs: [Data], satoshis: [UInt64], receivingAddresses: [String], utxos: [TxOutput]) -> Data {
        
        var rawTX = Data()
        rawTX += UInt32(0x00000001).littleEndian
        let numInputs: Data = variableIntegerAsData(forInt: utxos.count)
        rawTX += numInputs
        appendScriptSig(&rawTX, scriptSigs, utxos)
        let numAddresses: Data = variableIntegerAsData(forInt: receivingAddresses.count)
        rawTX += numAddresses
        appendAmountAndOutputScript(&rawTX, satoshis, receivingAddresses)
        // In this example, nLockTime is 0, meaning that there is no nLockTime specified and thus the transaction is executed immediately.
        #warning("TODO: Account for locktime")
        rawTX += UInt32(0x00000000)
        return rawTX
    }
    
    /// Variable Integer as Data
    ///
    /// - Parameter count: A number of bytes
    /// - Returns: A variable integer as Data
    ///
    /// See Also: [Reference Link](https://bitcoin.org/en/developer-reference#compactsize-unsigned-integers)
    ///
    /// For numbers from 0 to 252, compactSize unsigned integers look like regular unsigned integers.
    /// For other numbers up to 0xffffffffffffffff, a byte is prefixed to the number to indicate its length,
    /// but otherwise the numbers look like regular unsigned integers in little-endian order.
    ///
    /**
     Value                Bytes Used            Format
     <= 252                    1                uint8_t
     <= 0xffff                 3                0xfd followed by the number as uint16_t
     <= 0xffffffff             5                0xfe followed by the number as uint32_t
     <= 0xffffffffffffffff     9                0xff followed by the number as uint64_t
    For example, the number 515 is encoded as 0xfd0302.
     */
    func variableIntegerAsData(forInt count: Int) -> Data {
        #warning("TODO: Account for > 252")
        var myInt = UInt8(count)
        return Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
    }
    
    private func appendScriptSig(_ rawTX: inout Data, _ scriptSigs: [Data], _ utxos: [TxOutput]) {
        var coordinatedIndex = 0
        for utxo in utxos {
            rawTX += utxo.txid!
            if scriptSigs.count == utxos.count {
                rawTX += utxo.n!
                let myScriptSig = scriptSigs[coordinatedIndex]
                let size = UInt8(myScriptSig.count)
                rawTX += size
                rawTX += myScriptSig
            } else if coordinatedIndex == scriptSigs.count {
                rawTX += utxo.n!
                let myScriptPubKey = utxo.script
                let size = UInt8(myScriptPubKey!.count)
                rawTX += size
                rawTX += myScriptPubKey!
            } else {
                // The zeroes represent the 32 bit int "n", and size? byte
                let placeholderData = [UInt8](repeating: 0, count:5).data
                rawTX += placeholderData
            }
            // If non-zero locktime is used, then at least one input must have a seq number below 0xffffffff
            #warning("TODO: Account for sequence and locktime")
            rawTX += UInt32(0xffffffff)
            
            coordinatedIndex += 1
        }
    }

    private func appendAmountAndOutputScript(_ rawTX: inout Data, _ satoshis: [UInt64], _ receivingAddresses: [String]) {
        var counter = 0
        while counter < receivingAddresses.count {
            var satoshis = satoshis[counter].littleEndian
            rawTX += Data(bytes: &satoshis, count: MemoryLayout<UInt64>.size)
            rawTX += UInt8(0x19)
            // Then the actual output script:
            var scriptPubKey = Data()
            scriptPubKey += UInt8(0x76)
            scriptPubKey += UInt8(0xa9)
            scriptPubKey += UInt8(0x14)
            // FIXME: remove bang
            var address = receivingAddresses[counter].base58CheckDecode()!
            address.removeFirst() // Remove prefix byte
            scriptPubKey += address
            scriptPubKey += UInt8(0x88)
            scriptPubKey += UInt8(0xac)
            rawTX += scriptPubKey
            
            counter += 1
        }
    }
}
