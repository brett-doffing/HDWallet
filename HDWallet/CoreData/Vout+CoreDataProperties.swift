// Vout+CoreDataProperties.swift
//

import Foundation
import CoreData


extension Vout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vout> {
        return NSFetchRequest<Vout>(entityName: "Vout")
    }

    @NSManaged public var scriptPubKey: String?
    @NSManaged public var scriptPubKey_asm: String?
    @NSManaged public var scriptPubKey_address: String?
    @NSManaged public var scriptPubKey_type: String?
    @NSManaged public var value: Int64
    @NSManaged public var vin: Vin?
    @NSManaged public var transaction: Transaction?

}
