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
        
        // Safe-Check whether there's an authorized user
        guard DataHolder.sharedInstance.user != nil else {
            performSegue(withIdentifier: "LogIn", sender: self)
            return
        }
        
        // Some preparations for convenient work with keyboard
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        // Refreshing table's data
        // reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Set null footer for removing empty cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        
        // Ask for permission to send notifications
        permissionScope.addPermission(NotificationsPermission(), message: "We use this to send you\r\nspam and love notes")
        permissionScope.show()
        
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Safe-Check whether there's an authorized user
        guard DataHolder.sharedInstance.user != nil else {
            performSegue(withIdentifier: "LogIn", sender: self)
            return
        }
    }

    func reloadData() {
        userCoursesIndexes = DataHolder.sharedInstance.fetchCoursesIndexesForCurrentUser()
        tableView.reloadData()
    }
    
    // MARK: - DZEmptyDataSet
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Courses Yet")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "You can enroll to a new course by tapping '+' button using the promo-code your instructor has gave you.")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userCoursesIndexes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell

        // Configure the cell...
        
        let course = DataHolder.sharedInstance.courses[userCoursesIndexes[indexPath.row]]
        
        cell.courseName.text = course.name
        cell.instructorName.text = "\(course.instructor.firstName) \(course.instructor.lastName)"
        
        if let image = course.image {
            cell.courseImage.image = image
        } else {
            cell.courseImage.image = UIImage(named: "newCourseCover")
            cell.courseTypeLabel.text = course.type
        }
        
        if course.instructor.mail == DataHolder.sharedInstance.user!.mail {
            cell.adminImage.isHidden = false
        }

        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
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
        if DataHolder.sharedInstance.user!.isInstructor {
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "Create a New Course", style: .default, handler: {(UIAlertAction) -> Void in
                self.performSegue(withIdentifier: "CreateNewCourse", sender: self)
            }))
            ac.addAction(UIAlertAction(title: "Apply to the Course", style: .default, handler: {(UIAlertAction) -> Void in
                self.openPromoField()
            }))
            ac.addAction(UIAlertAction(title: NSAttributedString(string: "Cancel", attributes: [NSForegroundColorAttributeName: UIColor.red]).string, style: .cancel, handler: nil))
            // ac.view.tintColor = UIColor.darkText
            
            self.present(ac, animated: true, completion: nil)
        } else {
            openPromoField()
        }
    }
    
    func openPromoField() {
        let ac = UIAlertController(title: "Enter enroll code", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "CS193p"
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let promo = ac.textFields!.first!.text ?? ""
            
            if DataHolder.sharedInstance.validateCoursePromo(promo: promo) {
                DataHolder.sharedInstance.apply(current: DataHolder.sharedInstance.user!, to: ac.textFields!.first!.text ?? "")
                NetworkWorker.sharedInstance.applyUser(with: DataHolder.sharedInstance.user!.mail, to: ac.textFields!.first!.text ?? "")
                self.reloadData()
            }
        }))
        present(ac, animated: true, completion: nil)
    }
    
    
    // MARK: - Rewinding
    
    @IBAction func rewindToLibrary(_ sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func rewindToLibraryViewAndLogOut(_ sender: UIStoryboardSegue) {
        DataHolder.sharedInstance.user = nil
        performSegue(withIdentifier: "LogIn", sender: self)
    }
    
    @IBAction func saveCourse(_ sender: UIStoryboardSegue) {
        reloadData()
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
