//
//  AccountsViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 28/02/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import DATAStack
import DATASource
import MBProgressHUD

class AccountsViewController: UIViewController {
    // MARK: Variables
    var dataSource: DATASource?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        UpsalesAPI.sharedInstance.fetchAccounts({ error in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.dataSource = self.getDataSource(nil)
                self.tableView.reloadData()
            }
        })
    }

    func getDataSource(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>?) -> DATASource? {
        var request:NSFetchRequest<NSFetchRequestResult>?
        if let fetchRequest = fetchRequest {
            request = fetchRequest
        } else {
            request = NSFetchRequest(entityName: "Client")
            request!.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        }
        
        let dataSource = DATASource(tableView: tableView, cellIdentifier: "Cell", fetchRequest: request!, mainContext: API.sharedInstance.dataStack.mainContext, sectionName: nil, configuration: { cell, item, indexPath in
            if let account = item as? Client,
                let cell = cell as? UITableViewCell {
                
                self.configureCell(cell, withAccount: account)
            }
        })
        
        dataSource.delegate = self
        
        return dataSource
    }
    
    func configureCell(_ cell: UITableViewCell, account: Client) {
        cell.textLabel.text = account.name
        
    }
}

extension AccountsViewController: UITableViewDelegate {
    
}
