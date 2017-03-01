//
//  Address+CoreDataProperties.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 01/03/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address");
    }

    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var type: String?
    @NSManaged public var address: String?
    @NSManaged public var zipcode: String?
    @NSManaged public var country: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var geocodedAddress: String?

}
