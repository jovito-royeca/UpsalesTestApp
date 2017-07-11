//
//  CommonFilterViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 06/07/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import MBProgressHUD
import FontAwesome_swift

let kNotificationFilterKey = "kNotificationFilterKey"

@objc protocol CommonFilterViewControllerDelegate : NSObjectProtocol {
    func filterValue(filter: String) -> AnyObject?
    func loadFilterOptions(filter: String, completion: @escaping ([AnyObject]) -> Void)
    func saveFilter(filter: String, filterValue: AnyObject)
}

class CommonFilterViewController: UIViewController {

    var filters:[String]?
    var filterOptions: [AnyObject]?
    var selectedFilter: String?
    var selectedFilterOption: AnyObject?
    var delegate: CommonFilterViewControllerDelegate?
    var backButton: UIBarButtonItem?
    
    // MARK: Outlets
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        navigationItem.leftBarButtonItems = nil
        title = "Filter"
        filterOptions = nil
        selectedFilterOption = nil
        tableView.reloadData()
    }
    
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        navigationItem.leftBarButtonItems = nil
        title = "Filter"
        filterOptions = nil
        selectedFilterOption = nil
        mm_drawerController.toggle(.right, animated:true, completion:nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItems = nil
        
        view.backgroundColor = kUpsalesBlurredBlue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
}

// MARK: UITableViewDataSource
extension CommonFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        if let filterOptions = filterOptions {
            rows += filterOptions.count
        } else {
            if let filters = filters {
                rows = filters.count
            }
        }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if let filterOptions = filterOptions {
            cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell")
            let filterOption = filterOptions[indexPath.row]
            var selected = false
            
            if let selectedFilter = selectedFilter,
                let delegate = delegate {
                
                selected = filterOption.isEqual(delegate.filterValue(filter: selectedFilter))
            }

            
            if let imageView = cell?.contentView.viewWithTag(1) as? UIImageView {
                let width = imageView.frame.size.width
                imageView.layer.cornerRadius = width / 2
                imageView.layer.masksToBounds = true
                
                imageView.image = selected ? UIImage.fontAwesomeIcon(name: .checkCircle, textColor: UIColor.white, size: CGSize(width: width, height: width)) : nil
                imageView.backgroundColor = kUpsalesBrightBlue
            }
            
            if let label = cell?.contentView.viewWithTag(2) as? UILabel {
                label.text = filterOption.description
            }
            
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "MasterCell")
            
            if let filters = filters,
                let delegate = delegate {
                
                let filter = filters[indexPath.row]
                cell?.textLabel?.text = filter
                if let value = delegate.filterValue(filter: filter) {
                    cell?.detailTextLabel?.text = value.description
                } else {
                    cell?.detailTextLabel?.text = nil
                }
            }
        }
        
        cell?.textLabel?.textColor = UIColor.white
        cell?.detailTextLabel?.textColor = UIColor.white
        cell?.selectionStyle = .none

        return cell!
    }
}

// MARK: UITableViewDelegate
extension CommonFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            
            if let filterOptions = filterOptions{
                selectedFilterOption = filterOptions[indexPath.row]
                delegate.saveFilter(filter: selectedFilter!, filterValue: selectedFilterOption!)
                tableView.reloadData()
                
            } else {
                if let filters = filters {
                    MBProgressHUD.showAdded(to: view, animated: true)
                    selectedFilter = filters[indexPath.row]
                    delegate.loadFilterOptions(filter: selectedFilter!, completion: {(filterOptions: [AnyObject]) ->Void in
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.navigationItem.leftBarButtonItems = [self.backButton!]
                        self.title = self.selectedFilter
                        self.filterOptions = filterOptions
                        tableView.reloadData()
                    })
                }
            }
        }
    }
}

