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
    
    func fetchAccounts(completion: @escaping (NSError?) -> Void) {
        let urlString = "https://integration.upsales.com/api/v2/accounts/?token=\(kAPIToken)&limit=\(kFetchLimit)"
        
        Alamofire.request(urlString).responseJSON { response in
            if let json = response.result.value as? [String: Any] {
                if let data = json["data"] as? [[String: Any]] {
                    let notifName = NSNotification.Name.NSManagedObjectContextObjectsDidChange
                    
                    self.dataStack.performInNewBackgroundContext { backgroundContext in
                        NotificationCenter.default.addObserver(self, selector: #selector(UpsalesAPI.changeNotification(_:)), name: notifName, object: backgroundContext)
                        Sync.changes(data,
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