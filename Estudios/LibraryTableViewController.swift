//
//  LibraryTableViewController.swift
//  Estudios
//
//  Created by Sergey Popov on 9/23/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import PermissionScope

class LibraryTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var userCoursesIndexes = [Int]()
    let permissionScope = PermissionScope()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard DataHolder.sharedInstance.user != nil else {
            return
        }
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        permissionScope.addPermission(ContactsPermission(), message: "We use this to steal\r\nyour friends")
        permissionScope.addPermission(NotificationsPermission(), message: "We use this to send you\r\nspam and love notes")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        permissionScope.show()
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Courses Yet")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "You can enroll to a new course by tapping '+' button using the promo-code your instructor has gave you.")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard DataHolder.sharedInstance.user != nil else {
            performSegue(withIdentifier: "LogIn", sender: self)
            return
        }
        
        if !DataHolder.sharedInstance.user!.isInstructor {
            tabBarController?.tabBar.items!.last!.isEnabled = false
        } else {
            tabBarController?.tabBar.items!.last!.isEnabled = true
        }
    }
    
    func reloadData() {
        // TODO: - update userCoursesIndexes with .map(...)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userCoursesIndexes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell

        // Configure the cell...
        cell.courseName.text = DataHolder.sharedInstance.courses[indexPath.row].name
        cell.instructorName.text = "\(DataHolder.sharedInstance.courses[indexPath.row].instructor)"
        cell.courseImage.image = DataHolder.sharedInstance.courses[indexPath.row].image

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Add a New Course
    
    @IBAction func addNewCourse(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Enter enroll code", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "CS193p"
            })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            DataHolder.sharedInstance.add(current: DataHolder.sharedInstance.user!, to: ac.textFields!.first!.text ?? "")
            self.reloadData()
            }))
        present(ac, animated: true, completion: nil)
    }
    
    
    // MARK: - Rewinding
    
    @IBAction func rewindToLibrary(_ sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func rewindToLibraryViewAndLogOut(_ sender: UIStoryboardSegue) {
        DataHolder.sharedInstance.user = nil
    }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
