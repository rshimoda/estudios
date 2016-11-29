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
    
    let permissionScope = PermissionScope()
    let networkWorker = NetworkWorker()
    
    let user = DataHolder.sharedInstance.currentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Some preparations for convenient work with keyboard
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
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

    func reloadData() {
        networkWorker.get(user: user.mail) { user in
            DataHolder.sharedInstance.currentUser = user
            
            self.tableView.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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
        if user.courses.isEmpty && user.managedCourses.isEmpty {
            return 0
        } else if user.isInstructor {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if user.isInstructor {
            if section == 0 {
                return user.managedCourses.count
            } else {
                return user.courses.count
            }
        } else {
            return user.courses.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell

        // Configure the cell...
        if indexPath.section == 0 && user.isInstructor {
            let course = user.managedCourses[indexPath.row]
            
            cell.courseName.text = course.name
            cell.instructorName.text = "\(course.instructor.firstName) \(course.instructor.lastName)"
            
            if let image = course.image {
                cell.courseImage.image = image
            } else {
                cell.courseImage.image = UIImage(named: "newCourseCover")
                cell.courseTypeLabel.text = course.type
            }
        } else {
            let course = user.courses[indexPath.row]
            
            cell.courseName.text = course.name
            cell.instructorName.text = "\(course.instructor.firstName) \(course.instructor.lastName)"
            
            if let image = course.image {
                cell.courseImage.image = image
            } else {
                cell.courseImage.image = UIImage(named: "newCourseCover")
                cell.courseTypeLabel.text = course.type
            }
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && user.isInstructor {
            return "Managed Courses"
        } else if user.isInstructor {
            return "Other Courses"
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && user.isInstructor {
            DataHolder.sharedInstance.currentCourse = user.managedCourses[indexPath.row]
        } else {
            DataHolder.sharedInstance.currentCourse = user.courses[indexPath.row]
        }
        
        performSegue(withIdentifier: "Show Course", sender: self)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 
    
    // MARK: - Add a New Course
    
    @IBAction func addNewCourse(_ sender: UIBarButtonItem) {
        if user.isInstructor {
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
        ac.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            if let promo = ac.textFields!.first!.text {
                self.networkWorker.apply(user: self.user.mail, to: promo) {
                    self.reloadData()
                }
            }
        }))
        
        present(ac, animated: true, completion: nil)
    }
    
    
    // MARK: - Rewinding
    
    @IBAction func rewindToLibrary(_ sender: UIStoryboardSegue) {
        
    }
    
    
    @IBAction func saveCourse(_ sender: UIStoryboardSegue) {
        if let vc = sender.source as? CourseCreationFormViewController {
            networkWorker.save(course: vc.course) {
                self.reloadData()
            }
        }
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
