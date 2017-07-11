//
//  CommonViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 11/07/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit

class CommonViewController: UIViewController {

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: Custom methods
    func showMenu() {
        if let navigationVC = mm_drawerController.leftDrawerViewController as? UINavigationController {
            var menuView:MenuViewController?
            
            for drawer in navigationVC.viewControllers {
                if drawer is MenuViewController {
                    menuView = drawer as? MenuViewController
                }
            }
            if menuView == nil {
                menuView = MenuViewController()
                navigationVC.addChildViewController(menuView!)
            }
            
            navigationVC.popToViewController(menuView!, animated: true)
        }
        mm_drawerController.toggle(.left, animated:true, completion:nil)
    }
    
    func showFilter(withDelegate delegate: CommonFilterViewControllerDelegate, andFilters filters: [String]) {
        if let navigationVC = mm_drawerController.rightDrawerViewController as? UINavigationController {
            var filterView:CommonFilterViewController?
            
            for drawer in navigationVC.viewControllers {
                if drawer is CommonFilterViewController {
                    filterView = drawer as? CommonFilterViewController
                }
            }
            if filterView == nil {
                filterView = CommonFilterViewController()
                navigationVC.addChildViewController(filterView!)
            }
            
            filterView!.filters = filters
            filterView!.delegate = delegate
            navigationVC.popToViewController(filterView!, animated: true)
        }
        mm_drawerController.toggle(.right, animated:true, completion:nil)
    }
}
