//
//  InstructorViewController.swift
//  Estudios
//
//  Created by Sergey Popov on 12/15/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit

class InstructorViewController: UIViewController {

    @IBOutlet weak var instructorImage: UIImageView!
    @IBOutlet weak var instractorName: UILabel!
    @IBOutlet weak var InstructorMail: UILabel!
    @IBOutlet weak var aboutInstructor: UITextView!
    @IBOutlet weak var instructorInitials: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let instructor = DataHolder.sharedInstance.currentCourse.instructor
        instructorImage.image = instructor.image
        instructorInitials.text = "\(instructor.firstName.characters.first!)\(instructor.lastName.characters.first!)"
        instractorName.text = "\(instructor.firstName) \(instructor.lastName)"
        InstructorMail.text = instructor.mail
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

}
