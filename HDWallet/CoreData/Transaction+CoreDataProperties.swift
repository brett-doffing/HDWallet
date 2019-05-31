// Transaction+CoreDataProperties.swift
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var id: String?
    @NSManaged public var size: Int64
    @NSManaged public var locktime: Int64
    @NSManaged public var weight: Int64
    @NSManaged public var version: Int64
    @NSManaged public var fee: Int64
    @NSManaged public var block: Block?
    @NSManaged public var vin: NSSet?
    @NSManaged public var vout: NSSet?

}

// MARK: Generated accessors for vin
extension Transaction {

    @objc(addVinObject:)
    @NSManaged public func addToVin(_ value: Vin)

    @objc(removeVinObject:)
    @NSManaged public func removeFromVin(_ value: Vin)

    @objc(addVin:)
    @NSManaged public func addToVin(_ values: NSSet)

    @objc(removeVin:)
    @NSManaged public func removeFromVin(_ values: NSSet)

}

// MARK: Generated accessors for vout
extension Transaction {

    @objc(addVoutObject:)
    @NSManaged public func addToVout(_ value: Vout)

    @objc(removeVoutObject:)
    @NSManaged public func removeFromVout(_ value: Vout)

    @objc(addVout:)
    @NSManaged public func addToVout(_ values: NSSet)

    @objc(removeVout:)
    @NSManaged public func removeFromVout(_ values: NSSet)

}
