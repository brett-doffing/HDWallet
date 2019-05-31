// Vin+CoreDataProperties.swift
//

import Foundation
import CoreData


extension Vin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vin> {
        return NSFetchRequest<Vin>(entityName: "Vin")
    }

    @NSManaged public var isCoinbase: Bool
    @NSManaged public var scriptSig: String?
    @NSManaged public var scriptSig_asm: String?
    @NSManaged public var sequence: Int64
    @NSManaged public var txid: String?
    @NSManaged public var vout: Int64
    @NSManaged public var witness: NSObject?
    @NSManaged public var previousOut: Vout?
    @NSManaged public var transaction: Transaction?

}
