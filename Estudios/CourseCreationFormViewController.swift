//
//  CourseCreationFormViewController.swift
//  Estudios
//
//  Created by Sergey Popov on 11/11/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit
import Eureka

protocol CourseCreationDelegate {
    var course: Course! { get set }
}

class CourseCreationFormViewController: FormViewController, CourseCreationDelegate {
    
    var course: Course!
    
    func setCourse(newValue: Course) {
        self.course = newValue
    }
        
    override func viewDidLayoutSubviews() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            self.tableView?.contentInset = UIEdgeInsetsMake( y, 0, 0, 0)
        }
        
        print("Loaded with course \(course.name)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        form =
            Section()
            <<< TextRow() { row in
                row.title = "Duration"
                row.placeholder = "10 weeks"
                }.onChange { row in
                    self.course.duration = row.value ?? ""
                }

            
            +++ Section()
            <<< ActionSheetRow<String>() { row in
                row.title = "Level"
                row.selectorTitle = "Choose Required Level"
                row.options = ["A1", "A2", "B1", "B2"]
                row.value = "A2"
                }.onChange { row in
                    self.course.level = row.value ?? ""
            }
            <<< ActionSheetRow<String>() { row in
                row.title = "Type"
                row.selectorTitle = "Choose Type"
                row.options = ["Grammatics", "Lexis", "Specialization", "Common"]
                row.value = "Common"
                }.onChange {
                    self.course.type = $0.value ?? ""
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        print("Adding new course \(course.name)")
        DataHolder.sharedInstance.courses += [course]
        NetworkWorker.sharedInstance.save(new: course)
    }
 

}
