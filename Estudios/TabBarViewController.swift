//
//  TabBarViewController.swift
//  Estudios
//
//  Created by Sergey Popov on 12/2/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    let networkWorker = NetworkWorker()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func revindToTabBar(sender: UIStoryboardSegue) {
    
    }
}
