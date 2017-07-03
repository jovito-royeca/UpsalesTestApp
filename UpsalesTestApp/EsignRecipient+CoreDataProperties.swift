//
//  EsignRecipient+CoreDataProperties.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 29/06/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


extension EsignRecipient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EsignRecipient> {
        return NSFetchRequest<EsignRecipient>(entityName: "EsignRecipient")
    }

    @NSManaged public var sndname: String?
    @NSManaged public var declineMsg: String?
    @NSManaged public var contactId: Int32
    @NSManaged public var deliveryMethod: String?
    @NSManaged public var sign: NSDate?
    @NSManaged public var mobile: String?
    @NSManaged public var undelivered: Bool
    @NSManaged public var companynr: String?
    @NSManaged public var tsupdated: NSDate?
    @NSManaged public var userId: Int32
    @NSManaged public var seen: Bool
    @NSManaged public var signLink: String?
    @NSManaged public var esignId: Int32
    @NSManaged public var company: String?
    @NSManaged public var id: Int32
    @NSManaged public var declineDate: NSDate?
    @NSManaged public var authMethod: String?
    @NSManaged public var deliveryDate: NSDate?
    @NSManaged public var fstname: String?
    @NSManaged public var personalnr: String?
    @NSManaged public var email: String?
    @NSManaged public var esign: Esign?

}
