//
//  Client+CoreDataClass.swift
//  
//
//  Created by Jovito Royeca on 28/02/2017.
//
//

import Foundation
import CoreData

@objc(Client)
public class Client: NSManagedObject {
    func shortAddress() -> String? {
        if let addresses = addresses {
            if let addressArray = NSKeyedUnarchiver.unarchiveObject(with: addresses as Data) as? [[String: Any]] {
                for a in addressArray {
                    if let type = a["type"] as? String {
                        if type == "Visit" || type == "Mail" {
                            var addressString = ""
                            
                            if let city = a["city"] as? String {
                                addressString += "\(city)"
                            }
                            if let country = a["country"] as? String {
                                if let countryName = Locale.current.localizedString(forRegionCode: country) {
                                    if addressString.characters.count > 0 {
                                        addressString += ", "
                                    }
                                    addressString += "\(countryName)"
                                }
                            }
                            
                            return addressString
                        }
                    }
                }
            }
            
        }
        
        return nil
    }
    
    func completeAddress() -> String? {
        if let addresses = addresses {
            if let addressArray = NSKeyedUnarchiver.unarchiveObject(with: addresses as Data) as? [[String: Any]] {
                for a in addressArray {
                    if let type = a["type"] as? String {
                        if type == "Visit" || type == "Mail" {
                            var addressString = ""
                            
                            if let address = a["address"] as? String {
                                addressString += "\(address)"
                            }
                            if let city = a["city"] as? String {
                                if addressString.characters.count > 0 {
                                    addressString += ", "
                                }
                                addressString += "\(city)"
                            }
                            if let state = a["state"] as? String {
                                if addressString.characters.count > 0 {
                                    addressString += ", "
                                }
                                addressString += "\(state)"
                            }
                            if let country = a["country"] as? String {
                                if let countryName = Locale.current.localizedString(forRegionCode: country) {
                                    if addressString.characters.count > 0 {
                                        addressString += ", "
                                    }
                                    addressString += "\(countryName)"
                                }
                            }
                            if let zipcode = a["zipcode"] as? String {
                                if addressString.characters.count > 0 {
                                    addressString += " "
                                }
                                addressString += "\(zipcode)"
                            }
                            
                            return addressString
                        }
                    }
                }
            }
            
        }
        
        return nil
    }
    
    func accountManagers() -> [[String: Any]] {
        var array = [[String: Any]]()
        
        if let users = users {
            if let ams = NSKeyedUnarchiver.unarchiveObject(with: users as Data) as? [[String: Any]] {
                array = ams
            }
        }
        
        return array
    }
}
