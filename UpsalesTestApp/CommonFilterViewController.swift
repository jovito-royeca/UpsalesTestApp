//
//  CommonFilterViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 06/07/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit

class CommonFilter {
    var name: String?
    
    func doFilter() {
        
    }
}

class CommonFilterViewController: UIViewController {

    var filters:[CommonFilter]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    

}

extension CommonFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        if let filters = filters {
            rows = filters.count
        }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        return cell!
    }
}
