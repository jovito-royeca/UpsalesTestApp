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
    let searchController = UISearchController(searchResultsController: nil)
    var dataSource: DATASource?
    var indexTitles = [String]()
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        var userId:NSNumber?
        if let id = UserDefaults.standard.object(forKey: kUserDefaultFilterManagerID) as? NSNumber {
            userId = id
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        UpsalesAPI.sharedInstance.fetchAccounts(ofUser: userId, completion: { error in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.dataSource = self.getDataSource(nil)
                self.tableView.reloadData()
                
                if let error = error {
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
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
        case "showFilter"?:
            if let dest = segue.destination as? UINavigationController {
                if let filterVC = dest.childViewControllers.first as? FilterViewController {
                    filterVC.managers = UpsalesAPI.sharedInstance.fetchLocalManagers()
                }
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
            
            var userId:NSNumber?
            if let fm = UserDefaults.standard.object(forKey: kUserDefaultFilterManagerID) as? [String: Any] {
                // TODO: filter on users here... might need to create a relationship to user
            }
        }
        
        let dataSource = DATASource(tableView: tableView, cellIdentifier: "Cell", fetchRequest: request!, mainContext: UpsalesAPI.sharedInstance.dataStack.mainContext, sectionName: "sectionIndex", configuration: { cell, item, indexPath in
            if let account = item as? Client {
                
                self.configureCell(cell, withAccount: account)
            }
        })
        
        dataSource.delegate = self
        
        return dataSource
    }
    
    func configureCell(_ cell: UITableViewCell, withAccount account: Client) {
        cell.textLabel?.text = account.name
        cell.detailTextLabel?.text = account.shortAddress()
    }
    
    func filterAccounts(for searchText: String) {
        var request:NSFetchRequest<NSFetchRequestResult>?
        let count = searchText.characters.count
        
        if count > 0 {
            request = NSFetchRequest(entityName: "Client")
            request!.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            var predicate:NSPredicate?
            
            if count == 1 {
                predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", searchText)
            } else {
                predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            }
            request!.predicate = predicate
            
        }
            
        dataSource = getDataSource(request)
        tableView.reloadData()
    }
}

// MARK: DATASourceDelegate
extension AccountsViewController: DATASourceDelegate {
    func sectionIndexTitlesForDataSource(_ dataSource: DATASource, tableView: UITableView) -> [String] {
        indexTitles = [String]()
        
        if let accounts = dataSource.all() as? [Client] {
            for account in accounts {
                // add the First letter if alphabetic, else '#' for all other characters
                if let name = account.name {
                    if name.characters.count > 0 {
                        let range = name.startIndex..<name.index(name.startIndex, offsetBy: 1)
                        let substring = name[range]
                        
                        if !indexTitles.contains(substring) {
                            let letters = NSCharacterSet.letters
                            
                            if let _ = substring.rangeOfCharacter(from: letters) {
                                indexTitles.append(substring)
                            } else {
                                indexTitles.append("#")
                            }
                        }
                    } else {
                        indexTitles.append("#")
                    }
                }
            }
        }

        
        return indexTitles
    }
    
    func dataSource(_ dataSource: DATASource, tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if let indexOfTitle = indexTitles.index(of: title) {
            return indexOfTitle
        } else {
            return index
        }
    }
    
    func dataSource(_ dataSource: DATASource, tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.titleForHeader(section)
    }
}


// MARK: UITableViewDelegate
extension AccountsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = dataSource!.object(indexPath)
        performSegue(withIdentifier: "showAccountLocation", sender: account)
    }
}

// UISearchResultsUpdating
extension AccountsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterAccounts(for: searchController.searchBar.text!)
    }
}
