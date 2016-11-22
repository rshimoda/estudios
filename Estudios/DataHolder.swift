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
    
    func fetchCoursesIndexesForCurrentUser() -> [Int] {
        print("Fetching courses for user \(user!.mail)")
        print("All Courses: \(courses.map({$0.name}))")
        
        var indexesArray = [Int]()
        
        for  (index, course) in courses.enumerated() {
            if user!.mail == course.instructor.mail {
                indexesArray += [index]
                print("Found managed course \(course.name)")
                continue
            }
            
            for student in course.students {
                if student.mail == user!.mail {
                    indexesArray += [index]
                    break
                }
            }
        }
        
        return indexesArray
    }
    
    func apply(current user: User, to course: String) {
        for i in 0..<courses.count {
            if courses[i].promo == course && courses[i].instructor.mail != user.mail {
                courses[i].students += [user]
                return
            }
        }
    }
    
    func validateCoursePromo(promo: String) -> Bool{
        for course in courses {
            if course.promo == promo {
                return true
            }
        }
        return false
    }
}
