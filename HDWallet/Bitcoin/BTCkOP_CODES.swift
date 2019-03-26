// BTCkOP_CODES.swift

import Foundation

// MARK: Constants

/// An empty array of bytes is pushed onto the stack. (This is not a no-op: an item is added to the stack.)
let OP_0: UInt8 = 0x00; let OP_FALSE: UInt8 = 0x00
/// The next opcode bytes (1-75, 0x01-0x4b) is data to be pushed onto the stack.
///
/// - Parameter numBytes: Integer
/// - Returns: numBytes as UInt8
/// - Warning: Not an official OP_CODE
func OP_NUMBYTES(_ numBytes: Int) -> UInt8 { return UInt8(numBytes) }
/// The next byte contains the number of bytes to be pushed onto the stack.
let OP_PUSHDATA1: UInt8 = 0x4c
/// The next two bytes contain the number of bytes to be pushed onto the stack in little endian order.
let OP_PUSHDATA2: UInt8 = 0x4d
/// The next four bytes contain the number of bytes to be pushed onto the stack in little endian order.
let OP_PUSHDATA4: UInt8 = 0x4e
/// The number -1 is pushed onto the stack.
let OP_1NEGATE: UInt8 = 0x4f
/// The number 1 is pushed onto the stack.
let OP_1: UInt8 = 0x51; let OP_TRUE: UInt8 = 0x51
/// The number 2 is pushed onto the stack.
let OP_2: UInt8 = 0x52
/// The number 3 is pushed onto the stack.
let OP_3: UInt8 = 0x53
/// The number 4 is pushed onto the stack.
let OP_4: UInt8 = 0x54
/// The number 5 is pushed onto the stack.
let OP_5: UInt8 = 0x55
/// The number 6 is pushed onto the stack.
let OP_6: UInt8 = 0x56
/// The number 7 is pushed onto the stack.
let OP_7: UInt8 = 0x57
/// The number 8 is pushed onto the stack.
let OP_8: UInt8 = 0x58
/// The number 9 is pushed onto the stack.
let OP_9: UInt8 = 0x59
/// The number 10 is pushed onto the stack.
let OP_10: UInt8 = 0x5a
/// The number 11 is pushed onto the stack.
let OP_11: UInt8 = 0x5b
/// The number 12 is pushed onto the stack.
let OP_12: UInt8 = 0x5c
/// The number 13 is pushed onto the stack.
let OP_13: UInt8 = 0x5d
/// The number 14 is pushed onto the stack.
let OP_14: UInt8 = 0x5e
/// The number 15 is pushed onto the stack.
let OP_15: UInt8 = 0x5f
/// The number 16 is pushed onto the stack.
let OP_16: UInt8 = 0x60

// MARK: Flow Control

/// Does nothing.
let OP_NOP: UInt8 = 0x61
/// If the top stack value is not False, the statements are executed. The top stack value is removed.
let OP_IF: UInt8 = 0x63
/// If the top stack value is False, the statements are executed. The top stack value is removed.
let OP_NOTIF: UInt8 = 0x64
/// If the preceding OP_IF or OP_NOTIF or OP_ELSE was not executed then these statements are and if the preceding OP_IF or OP_NOTIF or OP_ELSE was executed then these statements are not.
let OP_ELSE: UInt8 = 0x67
/// Ends an if/else block. All blocks must end, or the transaction is invalid. An OP_ENDIF without OP_IF earlier is also invalid.
let OP_ENDIF: UInt8 = 0x68
/// Marks transaction as invalid if top stack value is not true. The top stack value is removed.
let OP_VERIFY: UInt8 = 0x69
/// Marks transaction as invalid. A standard way of attaching extra data to transactions is to add a zero-value output with a scriptPubKey consisting of OP_RETURN followed by exactly one pushdata op. Such outputs are provably unspendable, reducing their cost to the network. Currently it is usually considered non-standard (though valid) for a transaction to have more than one OP_RETURN output or an OP_RETURN output with more than one pushdata op.
let OP_RETURN: UInt8 = 0x6a

// MARK: Stack

/// Puts the input onto the top of the alt stack. Removes it from the main stack.
let OP_TOALTSTACK: UInt8 = 0x6b
/// Puts the input onto the top of the main stack. Removes it from the alt stack.
let OP_FROMALTSTACK: UInt8 = 0x6c
/// If the top stack value is not 0, duplicate it.
let OP_IFDUP: UInt8 = 0x73
/// Puts the number of stack items onto the stack.
let OP_DEPTH: UInt8 = 0x74
/// Removes the top stack item.
let OP_DROP: UInt8 = 0x75
/// Duplicates the top stack item.
let OP_DUP: UInt8 = 0x76
/// Removes the second-to-top stack item.
let OP_NIP: UInt8 = 0x77
/// Copies the second-to-top stack item to the top.
let OP_OVER: UInt8 = 0x78
/// The item n back in the stack is copied to the top.
let OP_PICK: UInt8 = 0x79
/// The item n back in the stack is moved to the top.
let OP_ROLL: UInt8 = 0x7a
/// The top three items on the stack are rotated to the left.
let OP_ROT: UInt8 = 0x7b
/// The top two items on the stack are swapped.
let OP_SWAP: UInt8 = 0x7c
/// The item at the top of the stack is copied and inserted before the second-to-top item.
let OP_TUCK: UInt8 = 0x7d
/// Removes the top two stack items.
let OP_2DROP: UInt8 = 0x6d
/// Duplicates the top two stack items.
let OP_2DUP: UInt8 = 0x6e
/// Duplicates the top three stack items.
let OP_3DUP: UInt8 = 0x6f
/// Copies the pair of items two spaces back in the stack to the front.
let OP_2OVER: UInt8 = 0x70
/// The fifth and sixth items back are moved to the top of the stack.
let OP_2ROT: UInt8 = 0x71
/// Swaps the top two pairs of items.
let OP_2SWAP: UInt8 = 0x72

// MARK: Splice

/// Pushes the string length of the top element of the stack (without popping it).
let OP_SIZE: UInt8 = 0x82

// MARK: Bitwise Logic

/// Returns 1 if the inputs are exactly equal, 0 otherwise.
let OP_EQUAL: UInt8 = 0x87
/// Same as OP_EQUAL, but runs OP_VERIFY afterward.
let OP_EQUALVERIFY: UInt8 = 0x88

// MARK: Arithmetic
// Note: Arithmetic inputs are limited to signed 32-bit integers, but may overflow their output.
// If any input value for any of these commands is longer than 4 bytes, the script must abort and fail.

/// 1 is added to the input.
let OP_1ADD: UInt8 = 0x8b
/// 1 is subtracted from the input.
let OP_1SUB: UInt8 = 0x8c
/// The sign of the input is flipped.
let OP_NEGATE: UInt8 = 0x8f
/// The input is made positive.
let OP_ABS: UInt8 = 0x90
/// If the input is 0 or 1, it is flipped. Otherwise the output will be 0.
let OP_NOT: UInt8 = 0x91
/// Returns 0 if the input is 0. 1 otherwise.
let OP_0NOTEQUAL: UInt8 = 0x92
/// a is added to b.
let OP_ADD: UInt8 = 0x93
/// b is subtracted from a.
let OP_SUB: UInt8 = 0x94
/// If both a and b are not "" (null string), the output is 1. Otherwise 0.
let OP_BOOLAND: UInt8 = 0x9a
/// If a or b is not "" (null string), the output is 1. Otherwise 0.
let OP_BOOLOR: UInt8 = 0x9b
/// Returns 1 if the numbers are equal, 0 otherwise.
let OP_NUMEQUAL: UInt8 = 0x9c
/// Same as OP_NUMEQUAL, but runs OP_VERIFY afterward.
let OP_NUMEQUALVERIFY: UInt8 = 0x9d
/// Returns 1 if the numbers are not equal, 0 otherwise.
let OP_NUMNOTEQUAL: UInt8 = 0x9e
/// Returns 1 if a is less than b, 0 otherwise.
let OP_LESSTHAN: UInt8 = 0x9f
/// Returns 1 if a is greater than b, 0 otherwise.
let OP_GREATERTHAN: UInt8 = 0xa0
/// Returns 1 if a is less than or equal to b, 0 otherwise.
let OP_LESSTHANOREQUAL: UInt8 = 0xa1
/// Returns 1 if a is greater than or equal to b, 0 otherwise.
let OP_GREATERTHANOREQUAL: UInt8 = 0xa2
/// Returns the smaller of a and b.
let OP_MIN: UInt8 = 0xa3
/// Returns the larger of a and b.
let OP_MAX: UInt8 = 0xa4
/// Returns 1 if x is within the specified range (left-inclusive), 0 otherwise.
let OP_WITHIN: UInt8 = 0xa5

// MARK: Crypto

/// The input is hashed using RIPEMD-160.
let OP_RIPEMD160: UInt8 = 0xa6
/// The input is hashed using SHA-1.
let OP_SHA1: UInt8 = 0xa7
/// The input is hashed using SHA-256.
let OP_SHA256: UInt8 = 0xa8
/// The input is hashed twice: first with SHA-256 and then with RIPEMD-160.
let OP_HASH160: UInt8 = 0xa9
/// The input is hashed two times with SHA-256.
let OP_HASH256: UInt8 = 0xaa
/// All of the signature checking words will only match signatures to the data after the most recently-executed OP_CODESEPARATOR.
let OP_CODESEPARATOR: UInt8 = 0xab
/// The entire transaction's outputs, inputs, and script (from the most recently-executed OP_CODESEPARATOR to the end) are hashed. The signature used by OP_CHECKSIG must be a valid signature for this hash and public key. If it is, 1 is returned, 0 otherwise.
let OP_CHECKSIG: UInt8 = 0xac
/// Same as OP_CHECKSIG, but OP_VERIFY is executed afterward.
let OP_CHECKSIGVERIFY: UInt8 = 0xad
/// Compares the first signature against each public key until it finds an ECDSA match. Starting with the subsequent public key, it compares the second signature against each remaining public key until it finds an ECDSA match. The process is repeated until all signatures have been checked or not enough public keys remain to produce a successful result. All signatures need to match a public key. Because public keys are not checked again if they fail any signature comparison, signatures must be placed in the scriptSig using the same order as their corresponding public keys were placed in the scriptPubKey or redeemScript. If all signatures are valid, 1 is returned, 0 otherwise. Due to a bug, one extra unused value is removed from the stack.
let OP_CHECKMULTISIG: UInt8 = 0xae
/// Same as OP_CHECKMULTISIG, but OP_VERIFY is executed afterward.
let OP_CHECKMULTISIGVERIFY: UInt8 = 0xaf

// MARK: Locktime

/// Marks transaction as invalid if the top stack item is greater than the transaction's nLockTime field, otherwise script evaluation continues as though an OP_NOP was executed. Transaction is also invalid if 1. the stack is empty; or 2. the top stack item is negative; or 3. the top stack item is greater than or equal to 500000000 while the transaction's nLockTime field is less than 500000000, or vice versa; or 4. the input's nSequence field is equal to 0xffffffff. The precise semantics are described in BIP 0065. (previously OP_NOP2)
let OP_CHECKLOCKTIMEVERIFY : UInt8 = 0xb1
/// Marks transaction as invalid if the relative lock time of the input (enforced by BIP 0068 with nSequence) is not equal to or longer than the value of the top stack item. The precise semantics are described in BIP 0112. (previously OP_NOP3)
let OP_CHECKSEQUENCEVERIFY : UInt8 = 0xb2

// MARK: Pseudo-words
// These words are used internally for assisting with transaction matching. They are invalid if used in actual scripts.

/// Represents a public key hashed with OP_HASH160.
let OP_PUBKEYHASH: UInt8 = 0xfd
/// Represents a public key compatible with OP_CHECKSIG.
let OP_PUBKEY: UInt8 = 0xfe
/// Matches any opcode that is not yet assigned.
let OP_INVALIDOPCODE: UInt8 = 0xff


