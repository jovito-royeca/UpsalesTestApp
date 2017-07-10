//
//  EsignFilterViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 05/07/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

let kEsignFilterSenderID = "esignFilterSenderID"
let kEsignFilterStatusID = "esignFilterStatusID"

class EsignFilterViewController: UIViewController {

    // MARK: Variables
    var senderId = Int32(-1)
    var statusId = Int32(-1)
    let statuses = [Int32(0), Int32(10), Int32(20), Int32(30), Int32(40)]
    var users:[User]?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: Actions
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        if senderId == -1 {
            UserDefaults.standard.removeObject(forKey: kEsignFilterSenderID)
        } else {
            UserDefaults.standard.set(senderId, forKey: kEsignFilterSenderID)
        }
        
        if statusId == -1 {
            UserDefaults.standard.removeObject(forKey: kEsignFilterStatusID)
        } else {
            UserDefaults.standard.set(statusId, forKey: kEsignFilterStatusID)
        }
        
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationEsignsFiltered), object: nil, userInfo: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let sid = UserDefaults.standard.object(forKey: kEsignFilterSenderID) as? Int32 {
            senderId = sid
        }
        
        if let sid = UserDefaults.standard.object(forKey: kEsignFilterStatusID) as? Int32 {
            statusId = sid
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        UpsalesAPI.sharedInstance.fetchUsers(completion: { error in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.updateData()
                
                if let error = error {
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }
    
    // MARK: Custom methods
    func updateData() {
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        users = try! UpsalesAPI.sharedInstance.dataStack.mainContext.fetch(request) as! [User]
        tableView.reloadData()
    }
}

// MARK: UITableViewDataSource
extension EsignFilterViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if let users = users {
                rows = users.count + 1
            }
        case 1:
            rows = 6
        default:
            rows = 0
        }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        var text:String?
        var selected = false
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            var sender = Int32(-1)
            
            switch indexPath.row {
            case 0:
                text = "All"
                sender = -1
            default:
                if let users = users {
                    let user = users[indexPath.row - 1]
                    text = user.name
                    sender = user.id
                }
            }
            selected = senderId == sender
        case 1:
            var status = Int32(-1)
            
            switch indexPath.row {
            case 0:
                text = "All"
                status = -1
            case 1:
                text = "Draft"
                status = 0
            case 2:
                text = "Waiting for sign"
                status = 10
            case 3:
                text = "Rejected"
                status = 20
            case 4:
                text = "Everyone has signed"
                status = 30
            case 5:
                text = "Cancelled"
                status = 40
            default:
                ()
            }
            selected = statusId == status
        default:
            ()
        }

        cell!.textLabel!.text = text
        cell!.accessoryType = selected ? .checkmark : .none
        
        return cell!
    }
}

// MARK: UITableViewDelegate
extension EsignFilterViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            switch indexPath.row {
            case 0:
                senderId = -1
            default:
                if let users = users {
                    let user = users[indexPath.row - 1]
                    senderId = user.id
                }
            }
        case 1:
            switch indexPath.row {
            case 0:
                statusId = -1
            case 1:
                statusId = statuses[0]
            case 2:
                statusId = statuses[1]
            case 3:
                statusId = statuses[2]
            case 4:
                statusId = statuses[3]
            case 5:
                statusId = statuses[4]
            default:
                ()
            }
        default:
            ()
        }
        
        tableView.reloadData()
        saveAction(UIBarButtonItem(title: "", style: .plain, target: nil, action: nil))
    }
}
