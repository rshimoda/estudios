//
//  PostsOutlineTableViewCell.swift
//  Estudios
//
//  Created by Sergey Popov on 12/15/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit

class PostsOutlineTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var counter: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
