//
//  User+CoreDataProperties.swift
//  
//
//  Created by Jovito Royeca on 28/02/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var role: NSData?
    @NSManaged public var email: String?
    @NSManaged public var clients: NSSet?
    @NSManaged public var esigns: NSSet?

}

// MARK: Generated accessors for clients
extension User {

    @objc(addClientsObject:)
    @NSManaged public func addToClients(_ value: Client)

    @objc(removeClientsObject:)
    @NSManaged public func removeFromClients(_ value: Client)

    @objc(addClients:)
    @NSManaged public func addToClients(_ values: NSSet)

    @objc(removeClients:)
    @NSManaged public func removeFromClients(_ values: NSSet)

}

// MARK: Generated accessors for esigns
extension User {
    
    @objc(addEsignsObject:)
    @NSManaged public func addToEsigns(_ value: Esign)
    
    @objc(removeEsignsObject:)
    @NSManaged public func removeFromEsigns(_ value: Esign)
    
    @objc(addEsigns:)
    @NSManaged public func addToEsigns(_ values: NSSet)
    
    @objc(removeEsigns:)
    @NSManaged public func removeFromEsigns(_ values: NSSet)
    
}
