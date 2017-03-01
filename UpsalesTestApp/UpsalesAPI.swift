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
    
    func fetchAccounts(ofUser userId: Int?, completion: @escaping (Error?) -> Void) {
        var urlString = "https://integration.upsales.com/api/v2/accounts/?token=\(kAPIToken)&limit=\(kFetchLimit)"
        
        if let userId = userId {
            urlString += "&user.id=\(userId)"
        }
        
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
                                         operations: [.Insert, .Update],
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
    
    func fetchLocalManagers() -> [User] {
        var localManagers = [User]()
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if let users = try! self.dataStack.mainContext.fetch(request) as? [User] {
            localManagers = users
        }

        return localManagers
    }
    
    func fetchLocalManager(withID id: Int) -> User? {
        var localManager:User?
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        request.predicate = NSPredicate(format: "id = \(id)")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if let users = try! self.dataStack.mainContext.fetch(request) as? [User] {
            localManager = users.first
        }
        
        return localManager
    }
    
    func disassociateAccountManagers() {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Client")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if let accounts = try! self.dataStack.mainContext.fetch(request) as? [Client] {
            for account in accounts {
                let users = account.mutableSetValue(forKey: "users")
                users.removeAllObjects()
            }
            do {
                try self.dataStack.mainContext.save()
            } catch let error {
                print("\(error)")
            }
        }
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
