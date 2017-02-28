//
//  FilterViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 28/02/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit

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
        
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let id = UserDefaults.standard.object(forKey: kUserDefaultFilterManagerID) as? NSNumber {
            manager = UpsalesAPI.sharedInstance.fetchLocalManager(withID: id)
        }
    }
}

// MARK: UITableViewDataSource
extension FilterViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        if let managers = managers {
            rows = managers.count
        }
        
        return rows
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.accessoryType = .none
        
        if let managers = managers {
            let m = managers[indexPath.row]
            
            cell.textLabel?.text = m.name
            
            if let manager = manager {
                if m.id == manager.id {
                    cell.accessoryType = .checkmark
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
        if let managers = managers {
            manager = managers[indexPath.row]
        }
        tableView.reloadData()
    }
}
