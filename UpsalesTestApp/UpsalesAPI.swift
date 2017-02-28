//
//  UpsalesAPI.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 28/02/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import Alamofire
import DATAStack
import Sync

let kAPIToken = "64d5a1669d5e6262c46f2c83637472f4271d1f7dc4f52c2127f4a14881419515"
let kFetchLimit = 100

class UpsalesAPI: NSObject {
    // MARK: Shared Instance
    static let sharedInstance = UpsalesAPI()
    
    // MARK: Variables
    let dataStack: DATAStack = DATAStack(modelName: "Upsales")
    
    func fetchAccounts(completion: @escaping (Error?) -> Void) {
        let urlString = "https://integration.upsales.com/api/v2/accounts/?token=\(kAPIToken)&limit=\(kFetchLimit)"
        
        Alamofire.request(urlString).responseJSON { response in
            if let error = response.error {
                completion(error)
            } else {
                if let json = response.result.value as? [String: Any] {
                    if let data = json["data"] as? [[String: Any]] {
                        let notifName = NSNotification.Name.NSManagedObjectContextObjectsDidChange
                        
                        // let us insert sectionIndex
                        var newData = [[String: Any]]()
                        for d in data {
                            var nd = [String: Any]()
                            
                            for (key,value) in d {
                                nd[key] = value
                                
                                if key == "name" {
                                    if let name = value as? String {
                                        // add the First letter if alphabetic, else '#' for all other characters
                                        if name.characters.count > 0 {
                                            let range = name.startIndex..<name.index(name.startIndex, offsetBy: 1)
                                            let substring = name[range]
                                            
                                            let letters = NSCharacterSet.letters
                                            if let _ = substring.rangeOfCharacter(from: letters) {
                                                nd["sectionIndex"] = substring
                                            } else {
                                                nd["sectionIndex"] = "#"
                                            }
                                            
                                        } else {
                                            nd["sectionIndex"] = "#"
                                        }
                                    }
                                }
                            }
                            newData.append(nd)
                        }
                        
                        
                        self.dataStack.performInNewBackgroundContext { backgroundContext in
                            NotificationCenter.default.addObserver(self, selector: #selector(UpsalesAPI.changeNotification(_:)), name: notifName, object: backgroundContext)
                            Sync.changes(newData,
                                         inEntityNamed: "Client",
                                         predicate: nil,
                                         parent: nil,
                                         parentRelationship: nil,
                                         inContext: backgroundContext,
                                         operations: .All,
                                         completion:  { error in
                                            NotificationCenter.default.removeObserver(self, name:notifName, object: nil)
                                            completion(nil)
                            })
                        }
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func fetchLocalManagers() -> [[String: Any]] {
        var localManagers = [[String: Any]]()
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Client")
        
        if let accounts = try! self.dataStack.mainContext.fetch(request) as? [Client] {
            for account in accounts {
                for manager in account.accountManagers() {
                    var existing = false
                    
                    for lm in localManagers {
                        if let mid = manager["id"] as? NSNumber,
                            let lmid = lm["id"] as? NSNumber {
                            
                            if mid.intValue == lmid.intValue {
                                existing = true
                                break
                            }
                        }
                    }
                    
                    if !existing {
                        localManagers.append(manager)
                    }
                }
            }
        }

        // sort by name
        localManagers.sort{
            (($0 as Dictionary<String, AnyObject>)["name"] as! String) < (($1 as Dictionary<String, AnyObject>)["name"] as! String)
        }
        
        // insert the default All filter
        localManagers.insert(["name": "All"], at: 0)
        
        return localManagers
    }
    
    func changeNotification(_ notification: Notification) {
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] {
            print("updatedObjects: \((updatedObjects as AnyObject).count!)")
        }
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] {
            print("deletedObjects: \((deletedObjects as AnyObject).count!)")
        }
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] {
            print("insertedObjects: \((insertedObjects as AnyObject).count!)")
        }
    }
}
