//
//  OutlineTableViewCell.swift
//  Estudios
//
//  Created by Sergey Popov on 12/15/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit

class OutlineTableViewCell: UITableViewCell {

    @IBOutlet weak var topicName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
