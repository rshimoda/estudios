//
//  GradesTableViewCell.swift
//  Estudios
//
//  Created by Sergey Popov on 12/10/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit

class GradesTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var studentImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
