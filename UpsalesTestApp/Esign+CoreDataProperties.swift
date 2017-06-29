//
//  Esign+CoreDataProperties.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 28/06/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


extension Esign {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Esign> {
        return NSFetchRequest<Esign>(entityName: "Esign")
    }

    @NSManaged public var localeRegion: String?
    @NSManaged public var authorization: Int32
    @NSManaged public var documentId: String?
    @NSManaged public var id: Int32
    @NSManaged public var involved: NSData?
    @NSManaged public var localeLanguage: String?
    @NSManaged public var mdate: NSDate?
    @NSManaged public var seenBySignatory: Bool
    @NSManaged public var state: Int32
    @NSManaged public var title: String?
    @NSManaged public var tsupdated: NSDate?
    @NSManaged public var type: Int32
    @NSManaged public var upsalesStatus: Int32
    @NSManaged public var version: Int32
    @NSManaged public var file: NSData?
    @NSManaged public var opportunity: String?
    @NSManaged public var orderStage: String?
    @NSManaged public var reminderDate: NSDate?
    @NSManaged public var user: User?
    @NSManaged public var client: Client?
    @NSManaged public var recipients: NSSet?

}

// MARK: Generated accessors for addresses
extension Esign {
    
    @objc(addRecipientsObject:)
    @NSManaged public func addToRecipients(_ value: EsignRecipient)
    
    @objc(removeRecipientsObject:)
    @NSManaged public func removeFromRecipients(_ value: EsignRecipient)
    
    @objc(addRecipients:)
    @NSManaged public func addToRecipients(_ values: NSSet)
    
    @objc(removeRecipients:)
    @NSManaged public func removeFromRecipients(_ values: NSSet)
    
}

