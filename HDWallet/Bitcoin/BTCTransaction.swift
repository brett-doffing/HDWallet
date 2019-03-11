// BTCTransaction.swift

import Foundation

public class BTCTransaction {
    
    static let shared = BTCTransaction()
    
    public func createTX(scriptSigs: [Data], satoshis: [UInt64], receivingAddresses: [String], utxos: [TxOutput]) -> Data {
        
        var rawTX = Data()
        
        // 1. Add four-byte version field: 01000000
        // The version in Little-Endian (reversed) format
        rawTX += UInt32(0x00000001).littleEndian
        
        // 2. One-byte varint specifying the number of inputs: 01
        // The number of input(s)/UTXO(s)
        let numInputs: Data = getVariableIntegerData(forInt: utxos.count)
        rawTX += numInputs
//        print(rawTX.toHexString())
//        let serializedUTXOs: Data = serializeUTXOs(utxos)
//        rawTX += serializedUTXOs
        
        // 3. 32-byte hash of the transaction from which we want to redeem an output:
        // Previous transaction output hash, in Little-Endian. This can be found in the transaction input (txid) from your block explorer
        
        // 4. Four-byte field denoting the output index we want to redeem from the transaction with the above hash (output number 2 = output index 1): 01000000
        // Output index output_no of the previous transaction in Little-Endian format. Again, can be found from your block explorer.
        
        // 5. Now comes the scriptSig. For the purpose of signing the transaction, this is temporarily filled with the scriptPubKey of the output we want to redeem. First we write a one-byte varint which denotes the length of the scriptSig (0x19 = 25 bytes): 19
        // The size (bytes) of the scriptSig or Unlocking Script that immediately follows. This value is in HEX as are all similar numbers and need to convert HEX to DEC to be human readable.
        
        // 6. Then we write the actual scriptSig (which is the scriptPubKey of the output we want to redeem):
        // PUSHDATA 47 - Size (in Bytes) to push to stack. This is also in HEX.
        
        // If there is a scriptSig for each output, then we can write the index, OR if we have n scriptSigs, we can assume that utxos[n] (utxos[coordinatedIndex]) would have the referencing index.  Else we insert 0's as a placeholder
        var coordinatedIndex = 0
        for utxo in utxos {
            rawTX += utxo.txid!
            rawTX += utxo.n!
            if scriptSigs.count == utxos.count {
                let myScriptSig = scriptSigs[coordinatedIndex]
                let size = UInt8(myScriptSig.count)
                rawTX += size
                rawTX += myScriptSig
            } else if coordinatedIndex == scriptSigs.count {
                let myScriptPubKey = utxo.script
                let size = UInt8(myScriptPubKey!.count)
                rawTX += size // How does this know to print 19 for 25 bytes?
                rawTX += myScriptPubKey!
            } else {
                let placeholderData = [UInt8](repeating: 0, count:5).data
                rawTX += placeholderData
            }
            // 7. Then we write a four-byte field denoting the sequence. This is currently always set to 0xffffffff: ffffffff
            // Sequence number, disabled for this transaction. However if non-zero locktime is used, then at least one input must have a seq number below 0xffffffff
            #warning("TODO: Account for sequence and locktime")
            rawTX += UInt32(0xffffffff)
            
            coordinatedIndex += 1
        }
//        print(rawTX.toHexString())
        // 8. Next comes a one-byte varint containing the number of outputs in our new transaction.
        let numAddresses: Data = getVariableIntegerData(forInt: receivingAddresses.count)
        rawTX += numAddresses
//        print(rawTX.toHexString())
        var counter = 0
        while counter < receivingAddresses.count {
            // 9. We then write an 8-byte field (64 bit integer) containing the amount we want to redeem from the specified output. I will set this to the total amount available in the output minus a fee of 0.001 BTC (0.999 BTC, or 99900000 Satoshis): 605af40500000000
            // Value to be transferred in Satoshi, in Little-Endian.
            // e784550100000000 = 15584e7
            var satoshis = satoshis[counter].littleEndian
            rawTX += Data(bytes: &satoshis, count: MemoryLayout<UInt64>.size)
            
            // 10. Then we start writing our transaction's output. We start with a one-byte varint denoting the length of the output script (0x19 or 25 bytes): 19
            // Size (in bytes) of the Locking Script (in this case, P2PKH) which follows. This is also in HEX.
            rawTX += UInt8(0x19)
            
            // 11. Then the actual output script:
            //
            var scriptPubKey = Data()
            scriptPubKey += UInt8(0x76)
            scriptPubKey += UInt8(0xa9)
            scriptPubKey += UInt8(0x14)
//            let address = base58CheckDecode(fromString: receivingAddresses[counter])!
            let address = "B48556E2DE495803E21EC650DE6C07BFB35E252C".unhexlify()
            scriptPubKey += address
            scriptPubKey += UInt8(0x88)
            scriptPubKey += UInt8(0xac)
            rawTX += scriptPubKey
            
            counter += 1
        }
//        print(rawTX.toHexString())
        // 9. We then write an 8-byte field (64 bit integer) containing the amount we want to redeem from the specified output. I will set this to the total amount available in the output minus a fee of 0.001 BTC (0.999 BTC, or 99900000 Satoshis): 605af40500000000
        // Value to be transferred in Satoshi, in Little-Endian.
        // e784550100000000 = 15584e7
        
        
        // 10. Then we start writing our transaction's output. We start with a one-byte varint denoting the length of the output script (0x19 or 25 bytes): 19
        // Size (in bytes) of the Locking Script (in this case, P2PKH) which follows. This is also in HEX.
        
        // 11. Then the actual output script:
        
        // 12. Then we write the four-byte "lock time" field: 00000000
        // nLockTime, can be either UNIX time or Block Height depending on usage.
        // Before this time, the transaction cannot be accepted into a block.
        // In this example, nLockTime is 0, meaning that there is no nLockTime specified and thus the transaction is executed immediately.
        #warning("TODO: Account for locktime")
        rawTX += UInt32(0x00000000)
        
        return rawTX
    }
    
     /**https://bitcoin.org/en/developer-reference#compactsize-unsigned-integers
     For numbers from 0 to 252, compactSize unsigned integers look like regular unsigned integers.
     For other numbers up to 0xffffffffffffffff, a byte is prefixed to the number to indicate its length,
     but otherwise the numbers look like regular unsigned integers in little-endian order.
     Value          Bytes Used        Format
     <= 252                 1                uint8_t
     <= 0xffff               3                0xfd followed by the number as uint16_t
     <= 0xffffffff           5                0xfe followed by the number as uint32_t
     <= 0xffffffffffffffff   9                0xff followed by the number as uint64_t
     For example, the number 515 is encoded as 0xfd0302.*/
    func getVariableIntegerData(forInt count: Int) -> Data {
        #warning("TODO: Account for > 252")
        var myInt = UInt8(count)
        return Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
    }
    
//    private func serializeUTXOs(_ utxos: [TxOutput]) -> Data {
//
//        return Data()
//    }
//
//    private func serializeReceivingAddresses(_ recvAddrs: [String]) -> Data {
//
//        return Data()
//    }
    
    // Decode
    func bytesFromBase58(_ base58: String) -> [UInt8] {
        let alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
        // remove leading and trailing whitespaces
        let string = base58.trimmingCharacters(in: CharacterSet.whitespaces)
        
        guard !string.isEmpty else { return [] }
        
        var zerosCount = 0
        var length = 0
        for c in string {
            if c != "1" { break }
            zerosCount += 1
        }
        
        let size = string.lengthOfBytes(using: String.Encoding.utf8) * 733 / 1000 + 1 - zerosCount
        var base58: [UInt8] = Array(repeating: 0, count: size)
        for c in string where c != " " {
            // search for base58 character
            guard let base58Index = alphabet.index(of: c) else { return [] }
            
            var carry = base58Index.encodedOffset
            var i = 0
            for j in 0...base58.count where carry != 0 || i < length {
                carry += 58 * Int(base58[base58.count - j - 1])
                base58[base58.count - j - 1] = UInt8(carry % 256)
                carry /= 256
                i += 1
            }
            
            assert(carry == 0)
            length = i
        }
        
        // skip leading zeros
        var zerosToRemove = 0
        
        for b in base58 {
            if b != 0 { break }
            zerosToRemove += 1
        }
        base58.removeFirst(zerosToRemove)
        
        var result: [UInt8] = Array(repeating: 0, count: zerosCount)
        for b in base58 {
            result.append(b)
        }
        return result
    }
    
    func base58CheckDecode(fromString myString: String) -> [UInt8]? {
        var bytes = bytesFromBase58(myString)
//        print(bytes)
        guard 4 <= bytes.count else { return nil }
        
        let checksum = [UInt8](bytes[bytes.count-4..<bytes.count])
        bytes = [UInt8](bytes[0..<bytes.count-4])
        
        let calculatedChecksum = Data(bytes: bytes).doubleSHA256().prefix(4).bytes
        
        if checksum != calculatedChecksum { print("not equal"); return nil }
//        print(bytes)
        return bytes
    }
}
