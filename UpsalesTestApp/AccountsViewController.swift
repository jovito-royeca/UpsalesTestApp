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
        MBProgressHUD.showAdded(to: view, animated: true)
        UpsalesAPI.sharedInstance.fetchAccounts(completion: { error in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.dataSource = self.getDataSource(nil)
                self.tableView.reloadData()
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showAccountLocation"?:
            if let dest = segue.destination as? AccountLocationViewController,
                let account = sender as? Client {
                
                dest.account = account
            }
        default:
            ()
        }
    }
    
    // MARK: CUstom methods
    func getDataSource(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>?) -> DATASource? {
        var request:NSFetchRequest<NSFetchRequestResult>?
        if let fetchRequest = fetchRequest {
            request = fetchRequest
        } else {
            request = NSFetchRequest(entityName: "Client")
            request!.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        }
        
        let dataSource = DATASource(tableView: tableView, cellIdentifier: "Cell", fetchRequest: request!, mainContext: UpsalesAPI.sharedInstance.dataStack.mainContext, sectionName: nil, configuration: { cell, item, indexPath in
            if let account = item as? Client {
                
                self.configureCell(cell, withAccount: account)
            }
        })
        
        dataSource.delegate = self
        
        return dataSource
    }
    
    func configureCell(_ cell: UITableViewCell, withAccount account: Client) {
        cell.textLabel?.text = account.name
        cell.detailTextLabel?.text = account.webpage
    }
}

// MARK: DATASourceDelegate
extension AccountsViewController: DATASourceDelegate {
    func sectionIndexTitlesForDataSource(_ dataSource: DATASource, tableView: UITableView) -> [String] {
        // return an empty String array to remove the section indexes
        return [String]()
    }
}


// MARK: UITableViewDelegate
extension AccountsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accounts = dataSource!.all()
        let account = accounts[indexPath.row]
        performSegue(withIdentifier: "showAccountLocation", sender: account)
    }
}
