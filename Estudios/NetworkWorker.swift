//
//  NetworkWorker.swift
//  Estudios
//
//  Created by Sergey Popov on 11/20/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkWorker {
    
    // MARK: - Host Adress
    
    static var host = "https://estudios-server.herokuapp.com" // "172.20.10.2"
    
    // MARK: - User
    
    func validate(user mail: String, with password: String, completion: @escaping (_ isValid: Bool) -> ()) {
        print("\n\n\nLooking for user \(mail)...")
        
        Alamofire.request("\(NetworkWorker.host)/validate", parameters: ["mail": mail, "password": password]).responseJSON { response in
            if let responseJSON = response.result.value {
                let json = JSON(responseJSON)
                
                completion(json.bool ?? false)
            }
        }
    }
    
    func get(user mail: String, completion: @escaping (_ user: User) -> ()) {
        print("\n\n\nFetching user \(mail)...")
        
        Alamofire.request("\(NetworkWorker.host)/user", parameters: ["mail": mail]).responseJSON { response in
            print("Result of response serialization: \(response.result)")

            if let JSONResponse = response.result.value {
                let json = JSON(JSONResponse)
                
                let user = User()
                
                let userJSON = json["user"].dictionary!
                let coursesJSON = json["courses"].array!
                let managedCoursesJSON = json["managedCourses"].array!
                
                user.id = userJSON["id"]?.int ?? 0
                user.mail = userJSON["mail"]?.string ?? ""
                user.password = userJSON["password"]?.string ?? ""
                user.firstName = userJSON["firstname"]?.string ?? ""
                user.lastName = userJSON["lastname"]?.string ?? ""
                user.isInstructor = userJSON["isinstructor"]?.bool ?? false
                
                for courseJSON in coursesJSON {
                    let course = Course()
                    
                    course.promo = courseJSON["promo"].string ?? ""
                    course.name = courseJSON["name"].string ?? ""
                    course.description = courseJSON["description"].string ?? ""
                    course.duration = courseJSON["duration"].string ?? ""
                    course.level = courseJSON["level"].string ?? ""
                    course.type = courseJSON["type"].string ?? ""
                    
                    if let instructor = courseJSON["instructor"].string {
                        self.get(instructor: instructor) { user in
                            course.instructor = user
                        }
                    }
                    
                    user.courses += [course]
                }
                
                for managedCourseJSON in managedCoursesJSON {
                    let managedCourse = Course()
                    
                    managedCourse.promo = managedCourseJSON["promo"].string ?? ""
                    managedCourse.name = managedCourseJSON["name"].string ?? ""
                    managedCourse.description = managedCourseJSON["description"].string ?? ""
                    managedCourse.duration = managedCourseJSON["duration"].string ?? ""
                    managedCourse.level = managedCourseJSON["level"].string ?? ""
                    managedCourse.type = managedCourseJSON["type"].string ?? ""
                    managedCourse.instructor = user
                    
                    user.managedCourses += [managedCourse]
                }
                
                completion(user)
            }
        }
    }
    
    func get(instructor mail: String, completion: @escaping (_ user: User) -> ()) {
        Alamofire.request("\(NetworkWorker.host)/instructor", parameters: ["mail": mail]).responseJSON { response in
            if let responseJSON = response.result.value {
                let json = JSON(responseJSON)
                
                let user = User()
                
                user.id = json["id"].int ?? 0
                user.mail = json["mail"].string ?? ""
                user.password = json["password"].string ?? ""
                user.firstName = json["firstname"].string ?? ""
                user.lastName = json["lastname"].string ?? ""
                user.isInstructor = json["isinstructor"].bool ?? false
                
                completion(user)
            }
        }
    }
    
    func apply(user mail: String, to course: String, completion: @escaping () -> ()) {
        print("\n\n\nAplying \(mail) to the course \(course)...")
        
        let request = Alamofire.request("\(NetworkWorker.host)/apply", method: .post, parameters: [ "mail":"\(mail)", "promo": "\(course)" ], encoding: JSONEncoding.default)
        
        print("Request Status Code: \(request.response?.statusCode)")
        
        completion()
    }
    
    func save(user: User, completion: @escaping () -> ()) {
        print("\n\n\nSaving new user \(user.mail)...")
        
        let parameters: [String : Any] = [
            "mail": user.mail,
            "password": user.password,
            "firstname": user.firstName,
            "lastname": user.lastName,
            "isinstructor": user.isInstructor
        ]
        let request = Alamofire.request("\(NetworkWorker.host)/newUser", method: .post, parameters: parameters, encoding: JSONEncoding.default)
        
        print("Request Status Code: \(request.response?.statusCode)")
        
        completion()
    }
    
    // MARK: - Course
    
    func get(course promo: String, completion: @escaping (_ user: Course) -> ()) {
        print("Fetching course \(promo)")
        
        Alamofire.request("\(NetworkWorker.host)/course", parameters: ["promo": promo]).responseJSON { response in
            print("Result of response serialization: \(response.result)")
            
            if let JSONResponse = response.result.value {
                let json = JSON(JSONResponse)
                
                let course = Course()
                course.promo = json["promo"].string ?? ""
                course.name = json["name"].string ?? ""
                course.description = json["description"].string ?? ""
                course.duration = json["duration"].string ?? ""
                course.level = json["level"].string ?? ""
                course.type = json["type"].string ?? ""

                if let instructor = json["instructor"].string {
                    self.get(instructor: instructor) { user in
                        course.instructor = user
                    }
                }
                
                completion(course)
            }
        }
    }
    
    func save(course: Course, completion: @escaping () -> ()) {

        print("\n\n\nSaving new course \(course.promo)...")
        
        let parameters = [
            "name": course.name,
            "description": course.description,
            "instructor": course.instructor.mail,
            "promo": course.promo,
            "duration": course.duration,
            "level": course.level,
            "type": course.type
        ]
        
        let request = Alamofire.request("\(NetworkWorker.host)/newCourse", method: .post, parameters: parameters, encoding: JSONEncoding.default)

        print("Request Status Code: \(request.response?.statusCode)")
        
        completion()
    }
    
    func update(course: Course) {
        print("\n\n\nUpdating course \(course.promo)...")
        
        let parameters = [
            "name": course.name,
            "description": course.description,
            "instructor": course.instructor.mail,
            "promo": course.promo,
            "duration": course.duration,
            "level": course.level,
            "type": course.type
        ]
        
        let request = Alamofire.request("\(NetworkWorker.host)/updateCourse", method: .post, parameters: parameters, encoding: JSONEncoding.default)
        
        print("Request Status Code: \(request.response?.statusCode)")
    }
}
