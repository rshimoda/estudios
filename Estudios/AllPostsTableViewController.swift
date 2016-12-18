//
//  AllPostsTableViewController.swift
//  Estudios
//
//  Created by Sergey Popov on 12/15/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class AllPostsTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var addLectureButton: UIBarButtonItem!
    
    let networkWorker = NetworkWorker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
        
        addLectureButton.isEnabled = DataHolder.sharedInstance.currentCourse.instructor.mail == DataHolder.sharedInstance.currentUser.mail && !DataHolder.sharedInstance.currentCourse.outline.isEmpty
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - DZEmptyDataSet
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Posts Yet")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "If instructor adds a new Post it will appear here.\nIf you're an Instructor - just tap '+' to do it.")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30.0
        } else {
            return 25.0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return DataHolder.sharedInstance.currentCourse.outline.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataHolder.sharedInstance.currentCourse.posts[DataHolder.sharedInstance.currentCourse.outline[section].topicId]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DataHolder.sharedInstance.currentCourse.outline[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LectureCell", for: indexPath) as! LectureTableViewCell

        // Configure the cell...
        guard let lecture = DataHolder.sharedInstance.currentCourse.posts[DataHolder.sharedInstance.currentCourse.outline[indexPath.section].topicId]?[indexPath.row] else {
            return cell
        }
        
        cell.lectureTitle.text = lecture.title
        cell.contents.text = lecture.contents
        cell.dateTitle.text = lecture.date

        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if DataHolder.sharedInstance.currentCourse.instructor.mail == DataHolder.sharedInstance.currentUser.mail {
            return true
        } else {
            return false
        }
    }
 
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            if let lecture = DataHolder.sharedInstance.currentCourse.posts[DataHolder.sharedInstance.currentCourse.outline[indexPath.section].topicId]?[indexPath.row] {
                self.networkWorker.delete(lecture: lecture) {
                    self.networkWorker.fetchTopics(for: DataHolder.sharedInstance.currentCourse.promo) {[weak self] topics in
                        guard let strongSelf = self else { return }
                        
                        DataHolder.sharedInstance.currentCourse.outline = topics
                        for topic in topics {
                            strongSelf.networkWorker.fetchLectures(for: topic) { lectures in
                                DataHolder.sharedInstance.currentCourse.posts[topic.topicId] = lectures
                            }
                        }
                        strongSelf.tableView.reloadData()
                    }

                }
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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
    
    @IBAction func revindToAllPosts(sender: UIStoryboardSegue) {
        self.tableView.reloadData()
    }
}
