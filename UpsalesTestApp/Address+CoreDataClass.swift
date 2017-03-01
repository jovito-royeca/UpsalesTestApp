//
//  Address+CoreDataClass.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 01/03/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData

@objc(Address)
public class Address: NSManagedObject {
    func shortAddress() -> String {

        var addressString = ""
        
        if let city = city {
            addressString += "\(city)"
        }
        if let country = country {
            if let countryName = Locale.current.localizedString(forRegionCode: country) {
                if addressString.characters.count > 0 {
                    addressString += ", "
                }
                addressString += "\(countryName)"
            }
        }
        
        return addressString
    }
    
    func completeAddress() -> String {
        var addressString = ""
        
        if let address = address {
            addressString += "\(address)"
        }
        if let city = city {
            if addressString.characters.count > 0 {
                addressString += ", "
            }
            addressString += "\(city)"
        }
        if let state = state {
            if addressString.characters.count > 0 {
                addressString += ", "
            }
            addressString += "\(state)"
        }
        if let country = country {
            if let countryName = Locale.current.localizedString(forRegionCode: country) {
                if addressString.characters.count > 0 {
                    addressString += ", "
                }
                addressString += "\(countryName)"
            }
        }
        if let zipcode = zipcode {
            if addressString.characters.count > 0 {
                addressString += " "
            }
            addressString += "\(zipcode)"
        }
        
        return addressString
    }
}
