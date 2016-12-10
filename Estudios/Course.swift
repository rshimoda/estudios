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
    
    // MARK: - Properties
    
    var name: String
    var description: String
    var image: UIImage?
    
    var duration: String
    var level: String
    var type: String
    
    var promo: String
    
    var instructor: User
    
    var students = [User]()
    let outline = [String]()
    
    // MARK: - Initializator
    
    init() {
        self.name = ""
        self.description = ""
        self.duration = ""
        self.level = ""
        self.type = ""
        self.promo = ""
        self.instructor = User()
    }
}
