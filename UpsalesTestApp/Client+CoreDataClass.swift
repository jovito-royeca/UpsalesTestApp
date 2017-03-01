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
    func findAddress() -> Address? {
        var address:Address?
        
        if let addresses = addresses {
            for a in addresses.allObjects {
                if let aa = a as? Address {
                    if aa.type == "Visit" {
                        address = aa
                        break
                    }
                }
            }
            
            if address == nil {
                for a in addresses.allObjects {
                    if let aa = a as? Address {
                        if aa.type == "Mail" {
                            address = aa
                            break
                        }
                    }
                }
            }
        }
        
        return address
    }
}
