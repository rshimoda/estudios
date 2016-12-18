//
//  LectureCreationTableViewController.swift
//  Estudios
//
//  Created by Sergey Popov on 12/15/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit

class LectureCreationTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let networkWorker = NetworkWorker()
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var topicTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet var pickerTopic: UIPickerView! = UIPickerView()
    
    var outlineDict = [String: String]()
    var outline = DataHolder.sharedInstance.currentCourse.outline
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for topic in DataHolder.sharedInstance.currentCourse.outline {
            outlineDict[topic.name] = topic.topicId
        }
        
        topicTextField.text = outline.first?.name ?? "No Topics"
        
        
        pickerTopic.delegate = self
        pickerTopic.dataSource = self
        
        self.topicTextField.inputView = pickerTopic
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Picker view delegate & datasource
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return outline.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return outline[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        topicTextField.text = outline[row].name
    }

    // MARK: - Table view data source
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
    
    @IBAction func saveLecture(_ sender: Any) {
        let lecture = Lecture(title: name.text ?? "", contents: descriptionTextField.text ?? "", date: "\(Date())", topicId: outlineDict[topicTextField.text!]!, lectureId: "\(outlineDict[topicTextField.text!]!)-\(DataHolder.sharedInstance.currentCourse.posts[outlineDict[topicTextField.text!]!]?.count)")
        networkWorker.save(lecture: lecture) { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.networkWorker.fetchTopics(for: DataHolder.sharedInstance.currentCourse.promo) { [weak self] topics in
                guard let strongSelf = self else { return }
                
                DataHolder.sharedInstance.currentCourse.outline = topics
                for topic in topics {
                    strongSelf.networkWorker.fetchLectures(for: topic) { lectures in
                        DataHolder.sharedInstance.currentCourse.posts[topic.topicId] = lectures
                    }
                }
                strongSelf.dismiss(animated: true, completion: nil)
            }
        }
        
    }

}
