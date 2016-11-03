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
    let mail: String
    let password: String
    
    let firstName: String
    let lastName: String
    
    var image: UIImage?
    
    let isInstructor: Bool
    
    init(mail: String, password: String, firstName: String, lastName: String, isInstructor: Bool) {
        self.mail = mail
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.image = nil
        self.isInstructor = isInstructor
    }
}
