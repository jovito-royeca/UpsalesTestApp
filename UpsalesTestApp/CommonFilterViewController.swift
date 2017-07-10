//
//  CommonFilterViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 06/07/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import MBProgressHUD

let kNotificationFilterLoaded = "kNotificationFilterLoaded"
let kNotificationFilterKey = "kNotificationFilterKey"

@objc protocol CommonFilterViewControllerDelegate : NSObjectProtocol {
    func x()
}

class CommonFilterViewController: UIViewController {

    var filters:[[String:[AnyObject]]]?
    var filter:[String:[AnyObject]]?
    var delegate:CommonFilterViewControllerDelegate?
    
    // MARK: Outlets
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        mm_drawerController.toggle(.right, animated:true, completion:nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotificationFilterLoaded), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommonFilterViewController.filterLoaded(_:)), name: NSNotification.Name(rawValue: kNotificationFilterLoaded), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommonFilterViewController.filterLoaded(_:)), name: NSNotification.Name(rawValue: kNotificationFilterLoaded), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showFilterDetails"?:
            if let dest = segue.destination as? CommonFilterViewController {
                print("segueing...")
            }
        default:
            ()
        }
    }
    
    // MARK: Custom methods
    func filterLoaded(_ notification: Notification) {
        if let fs = notification.userInfo?[kNotificationFilterKey] as? [[String:[AnyObject]]] {
            filters = fs
            tableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}

extension CommonFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        if let filter = filter {
            for (_,value) in filter {
                rows += value.count
            }
        } else {
            if let filters = filters {
                rows = filters.count
            }
        }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if let filter = filter {
            cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell")
            
            for (_,value) in filter {
                let v = value[indexPath.row]
                cell?.textLabel?.text = v.description
            }
            
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "MasterCell")
            
            if let filters = filters {
                let filter = filters[indexPath.row]
                cell?.textLabel?.text = filter.keys.first
            }
        }
        
        return cell!
    }
}
