//
//  User+CoreDataClass.swift
//  
//
//  Created by Jovito Royeca on 28/02/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {

    var initials: String? {
        var text:String?
        
        if let name = name {
            text = ""
            
            for n in name.components(separatedBy: " ") {
                if let initial = n.characters.first {
                    text!.append(String(initial))
                }
            }
        }
        
        return text
    }
}
