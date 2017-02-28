//
//  Client+CoreDataProperties.swift
//  
//
//  Created by Jovito Royeca on 28/02/2017.
//
//

import Foundation
import CoreData


extension Client {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client");
    }

    @NSManaged public var addresses: NSData?
    @NSManaged public var assigned: NSData?
    @NSManaged public var categories: NSData?
    @NSManaged public var connectedClients: NSData?
    @NSManaged public var custom: NSData?
    @NSManaged public var dunsNo: Int64
    @NSManaged public var fax: String?
    @NSManaged public var hadActivity: NSDate?
    @NSManaged public var hasActivity: NSDate?
    @NSManaged public var hasAppointment: NSDate?
    @NSManaged public var hasForm: Bool
    @NSManaged public var hasMail: Bool
    @NSManaged public var hasOpportunity: NSDate?
    @NSManaged public var hasOrder: NSDate?
    @NSManaged public var hasVisit: Bool
    @NSManaged public var id: Int32
    @NSManaged public var modDate: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var parent: NSData?
    @NSManaged public var phone: String?
    @NSManaged public var projects: NSData?
    @NSManaged public var regBy: NSData?
    @NSManaged public var regDate: NSDate?
    @NSManaged public var score: Int32
    @NSManaged public var scoreUpdateDate: NSDate?
    @NSManaged public var sectionIndex: String?
    @NSManaged public var soliditet: NSData?
    @NSManaged public var userEditable: Bool
    @NSManaged public var userRemovable: Bool
    @NSManaged public var users: NSData?
    @NSManaged public var webpage: String?

}
