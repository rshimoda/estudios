//
//  InfoViewController.swift
//  Estudios
//
//  Created by Sergey Popov on 12/11/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var promoLabel: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var instructor: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let course = DataHolder.sharedInstance.currentCourse!
        
        image.image = course.image ?? UIImage(named: "newCourseCover")
        nameLabel.text = course.name
        promoLabel.text = course.promo
        duration.text = course.duration
        level.text = course.level
        instructor.text = "\(course.instructor.firstName) \(course.instructor.lastName)"
        type.text = course.type
        descriptionTextField.text = course.description
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
