//
//  EsignFilterViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 05/07/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit

let kEsignFilterSenderID = "esignFilterSenderID"
let kEsignFilterStatusID = "esignFilterStatusID"

class EsignFilterViewController: UIViewController {

    // MARK: Variables
    var selectedSenderIndex = 0
    var selectedStatusIndex = 0
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: Actions
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        var esignFilterSenderId = 0
        var esignFilterStatusId = 0
        
        switch selectedStatusIndex {
            case 0:
                esignFilterStatusId =  -1
            case 1:
                esignFilterStatusId =  0
            case 2:
                esignFilterStatusId =  10
            case 3:
                esignFilterStatusId =  20
            case 4:
                esignFilterStatusId =  30
            case 5:
                esignFilterStatusId =  40
            default:
            ()
        }
        
        if esignFilterStatusId == -1 {
            UserDefaults.standard.removeObject(forKey: kEsignFilterStatusID)
        } else {
            UserDefaults.standard.set(esignFilterStatusId, forKey: kEsignFilterStatusID)
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
        if let statusId = UserDefaults.standard.object(forKey: kEsignFilterStatusID) as? Int {
            switch statusId {
            case 0:
                selectedStatusIndex = 1
            case 10:
                selectedStatusIndex = 2
            case 20:
                selectedStatusIndex = 3
            case 30:
                selectedStatusIndex = 4
            case 40:
                selectedStatusIndex = 5
            default:
                ()
            }
        }
    }
}

// MARK: UITableViewDataSource
extension EsignFilterViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            rows = 1
        case 1:
            rows = 7
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
            ()
        case 1:
            switch indexPath.row {
            case 0:
                text = "All"
            case 1:
                text = "Draft"
            case 2:
                text = "Waiting for sign"
            case 3:
                text = "Rejected"
            case 4:
                text = "Everyone has signed"
            case 5:
                text = "Cancelled"
            default:
                ()
            }
            selected = selectedStatusIndex == indexPath.row
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
            selectedSenderIndex = indexPath.row
        case 1:
            selectedStatusIndex = indexPath.row
        default:
            ()
        }
        
        tableView.reloadData()
    }
}
