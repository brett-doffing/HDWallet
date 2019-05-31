// Block+CoreDataProperties.swift
//

import Foundation
import CoreData


extension Block {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Block> {
        return NSFetchRequest<Block>(entityName: "Block")
    }

    @NSManaged public var blockHash: String?
    @NSManaged public var blockTime: Int64
    @NSManaged public var blockHeight: Int64
    @NSManaged public var confirmed: Bool
    @NSManaged public var transaction: Transaction?

}
