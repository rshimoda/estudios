//
//  User.swift
//  Estudios
//
//  Created by Sergey Popov on 9/23/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import Foundation
import UIKit

class User {
    
    // MARK: - Properties
    
    var id: Int
    
    var mail: String
    var password: String
    
    var firstName: String
    var lastName: String
    
    var image: UIImage?
    
    var isInstructor: Bool
    
    var courses = [Course]()
    var managedCourses = [Course]()
    
    // MARK: - Initializer
    
    init() {
        self.id = 0
        self.mail = ""
        self.password = ""
        self.firstName = ""
        self.lastName = ""
        self.isInstructor = false
    }
}
