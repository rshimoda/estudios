//
//  DataHolder.swift
//  Estudios
//
//  Created by Sergey Popov on 9/23/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import Foundation
import UIKit

class DataHolder {
    
    static let sharedInstance = DataHolder()
    
    var user: User?
    var users = [String: User]() {
        willSet {
            for (mail, user) in newValue {
                usersVerificationData[mail] = user.password
            }
        }
    }
    var usersVerificationData = [String: String]()
    
    var courses = [Course]()
    
    func loadUsers() {
        let firstUser = User(mail: "admin@mail.com", password: "123", firstName: "Johnny", lastName: "Appleseed", isInstructor: true)
//        do {
//            firstUser.image = try UIImage(data: Data(contentsOf: URL(string: "http://www.iclarified.com/images/news/54246/54246/54246-1280.jpg")!))
//        } catch {
//            print("Failed to load image")
//        }
        DataHolder.sharedInstance.users["admin@mail.com"] = firstUser
        
        DataHolder.sharedInstance.users["user@mail.com"] = User(mail: "user@mail.com", password: "123", firstName: "System", lastName: "User", isInstructor: false)
    }
    
    func add(current user: User, to course: String) {
        for i in 0..<courses.count {
            if courses[i].promo == course && courses[i].instructor.mail != user.mail {
                courses[i].students += [user]
                return
            }
        }
    }
}
