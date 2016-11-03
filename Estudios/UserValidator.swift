//
//  UserValidator.swift
//  Estudios
//
//  Created by Sergey Popov on 9/24/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import Foundation

class UserValidator {
    static func validateUser(with email: String, and password: String) -> Bool {
        if let passwordForEmail = DataHolder.sharedInstance.usersVerificationData[email] {
            if password == passwordForEmail {
                return true
            }
        }
        return false
    }
    
    static func getUser(with email: String, and password: String) -> User? {
        if let user = DataHolder.sharedInstance.users[email] {
            if user.password == password {
                return user
            }
        }
        return nil
    }
}
