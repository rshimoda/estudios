//
//  OverviewViewController.swift
//  Estudios
//
//  Created by Sergey Popov on 11/28/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit

class OverviewViewController: UISplitViewController, UISplitViewControllerDelegate {

    
    //MARK: - View Loading

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }

    //MARK: - Split View Controller
    
    //MARK: - Split View Controller Delegate
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
}
