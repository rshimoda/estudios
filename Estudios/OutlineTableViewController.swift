//
//  OutlineTableViewController.swift
//  Estudios
//
//  Created by Sergey Popov on 12/15/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit

class OutlineTableViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var outline = DataHolder.sharedInstance.currentCourse.outline
    
    let networkWorker = NetworkWorker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButton.isEnabled = DataHolder.sharedInstance.currentCourse.instructor.mail == DataHolder.sharedInstance.currentUser.mail
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
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
        return outline.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OutlineCell", for: indexPath) as! OutlineTableViewCell

        // Configure the cell...
        cell.topicName.text = outline[indexPath.row].name

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            networkWorker.delete(topic: outline[indexPath.row]) {
                self.outline.remove(at: indexPath.row)
                DataHolder.sharedInstance.currentCourse.outline.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
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
    
    @IBAction func addOutline(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Add New Topic", message: "Please enter a name of a new topic below.", preferredStyle: .alert)
        ac.addTextField(configurationHandler: { textField in
            textField.placeholder = "Introduction"
        })
        ac.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            if let topicName = ac.textFields?.first?.text {
                let topic = Topic(promo: DataHolder.sharedInstance.currentCourse.promo, topicId: "\(DataHolder.sharedInstance.currentCourse.promo)-\(self.outline.count + 1)", name: topicName)
                
                self.networkWorker.save(topic: topic, completion: {
                    self.networkWorker.fetchTopics(for: DataHolder.sharedInstance.currentCourse.promo) { topics in
                        DataHolder.sharedInstance.currentCourse.outline.append(topic)
                        self.outline += [topic]
                        self.tableView.reloadData()
                    }
                })
            }
        }))
        ac.view.tintColor = UIColor.flatGreenColorDark()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(ac, animated: true, completion: nil)
    }

}
