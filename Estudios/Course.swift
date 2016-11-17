//
//  Course.swift
//  Estudios
//
//  Created by Sergey Popov on 10/2/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import Foundation
import UIKit

class Course {
    var name: String
    var description: String
    var image: UIImage?
    
    var duration: String
    var level: String
    var type: String
    
    let promo: String
    
    let instructor: User
    var students = [User]()
    
    let outline = [String]()
    
    init(name: String, description: String, instructor: User, promo: String) {
        self.name = name
        self.description = description
        self.instructor = instructor
        self.promo = promo
        self.duration = ""
        self.level = ""
        self.type = ""
    }
    
}
