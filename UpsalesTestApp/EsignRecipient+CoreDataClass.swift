//
//  EsignRecipient+CoreDataClass.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 29/06/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData

@objc(EsignRecipient)
public class EsignRecipient: NSManagedObject {
    
    var initials: String? {
        var text:String?
        
        if let fstname = fstname{
            text = ""
            
            if let initial = fstname.characters.first {
                text!.append(String(initial))
            }
        }
        
        if let sndname = sndname {
            if text == nil {
                text = ""
            }
            
            if let initial = sndname.characters.first {
                text!.append(String(initial))
            }
        }
        
        return text
    }
}
