//
//  FilterViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 28/02/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import MBProgressHUD

let kUserDefaultFilterManagerID = "filterManagerID"

class FilterViewController: UIViewController {

    // MARK: Variables
    var managers:[User]?
    var manager:User?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        var userId:Int?
        if let manager = manager {
            userId = Int(manager.id)
            UserDefaults.standard.set(userId, forKey: kUserDefaultFilterManagerID)
        } else {
            UserDefaults.standard.removeObject(forKey: kUserDefaultFilterManagerID)
        }
        UserDefaults.standard.synchronize()
        
        MBProgressHUD.showAdded(to: view, animated: true)
        UpsalesAPI.sharedInstance.disassociateAccountManagers()
        UpsalesAPI.sharedInstance.fetchAccounts(ofUser: userId, completion: { error in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let error = error {
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAccountsFiltered), object: nil, userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let id = UserDefaults.standard.object(forKey: kUserDefaultFilterManagerID) as? Int {
            manager = UpsalesAPI.sharedInstance.fetchLocalManager(withID: id)
        }
    }
}

// MARK: UITableViewDataSource
extension FilterViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        if let managers = managers {
            rows = managers.count + 1
        }
        
        return rows
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "None"
            cell.accessoryType = manager == nil ? .checkmark : .none
        } else {
            if let managers = managers {
                let m = managers[indexPath.row - 1]
                
                cell.textLabel?.text = m.name
//                print("\(m.id): \(m.name!)")
                
                if let manager = manager {
                    if m.id == manager.id {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                } else {
                    cell.accessoryType = .none
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Account Managers"
    }
    
}

// MARK: UITableViewDelegate
extension FilterViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            manager = nil
        } else {
            if let managers = managers {
                manager = managers[indexPath.row - 1]
            }
        }
        
        tableView.reloadData()
    }
}
