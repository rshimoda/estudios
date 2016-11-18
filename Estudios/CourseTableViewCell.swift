//
//  CourseTableViewCell.swift
//  Estudios
//
//  Created by Sergey Popov on 9/26/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var instructorName: UILabel!
    @IBOutlet weak var courseImage: UIImageView!
    @IBOutlet weak var adminImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
