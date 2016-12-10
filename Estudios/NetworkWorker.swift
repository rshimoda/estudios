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
                
                print("JSON: ")
                debugPrint(json)
                
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
                    let courseDataJSON = courseJSON["course"].dictionary!
                    let instructorDataJSON = courseJSON["instructor"].dictionary!
                    let studentsJSON = courseJSON["students"].array!
                    
                    let course = Course()
                    
                    course.promo = courseDataJSON["promo"]?.string ?? ""
                    course.name = courseDataJSON["name"]?.string ?? ""
                    course.description = courseDataJSON["description"]?.string ?? ""
                    course.duration = courseDataJSON["duration"]?.string ?? ""
                    course.level = courseDataJSON["level"]?.string ?? ""
                    course.type = courseDataJSON["type"]?.string ?? ""
                    
                    let instructor = User()
                    
                    instructor.mail = instructorDataJSON["mail"]?.string ?? ""
                    instructor.firstName = instructorDataJSON["firstname"]?.string ?? ""
                    instructor.lastName = instructorDataJSON["lastname"]?.string ?? ""
                    
                    course.instructor = instructor
                    
                    var students = [User]()
                    
                    for studentJSON in studentsJSON {
                        let student = User()
                        student.mail = studentJSON["mail"].string ?? ""
                        student.firstName = studentJSON["firstname"].string ?? ""
                        student.lastName = studentJSON["lastname"].string ?? ""
                        students.append(student)
                    }
                    
                    course.students = students
                    
                    print("Adding course \(course.promo)")
                    
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
                    
                    print("Adding managed course \(managedCourse.promo)")
                    
                    user.managedCourses += [managedCourse]
                }
                
                print("Done. Running completion closure...")
                completion(user)
            }
        }
    }
    
    func get(instructor mail: String, completion: @escaping (_ user: User) -> ()) {
        print("\n\n\nFetching instructor \(mail) data...")
        Alamofire.request("\(NetworkWorker.host)/instructor", parameters: ["mail": mail]).responseJSON { response in
            if let responseJSON = response.result.value {
                let json = JSON(responseJSON)
                
                print("JSON: ")
                debugPrint(json)
                
                let user = User()
                
                user.id = json["id"].int ?? 0
                user.mail = json["mail"].string ?? ""
                user.password = json["password"].string ?? ""
                user.firstName = json["firstname"].string ?? ""
                user.lastName = json["lastname"].string ?? ""
                user.isInstructor = json["isinstructor"].bool ?? false
                
                print("Done. Running completion closure...")
                completion(user)
            }
        }
    }
    
    
    /*
    func getCourses(for user: String, completion: @escaping (_ courses: [Course]) -> ()) {
        print("\n\n\nFetching coursesfor user \(user)...")
        Alamofire.request("\(NetworkWorker.host)/courses", parameters: ["mail": user]).responseJSON { response in
            if let responseJSON = response.result.value {
                let json = JSON(responseJSON).array!
                
                print("JSON: ")
                debugPrint(json)
                
                var courses = [Course]()
                
                for courseJSON in json {
                    let courseDataJSON = courseJSON["course"].dictionary!
                    let instructorDataJSON = courseJSON["instructor"].dictionary!
                    
                    let course = Course()
                    
                    course.promo = courseDataJSON["promo"]?.string ?? ""
                    course.name = courseDataJSON["name"]?.string ?? ""
                    course.description = courseDataJSON["description"]?.string ?? ""
                    course.duration = courseDataJSON["duration"]?.string ?? ""
                    course.level = courseDataJSON["level"]?.string ?? ""
                    course.type = courseDataJSON["type"]?.string ?? ""
                    
                    let instructor = User()
                    
                    instructor.mail = instructorDataJSON["mail"]?.string ?? ""
                    instructor.firstName = instructorDataJSON["firstname"]?.string ?? ""
                    instructor.lastName = instructorDataJSON["lastname"]?.string ?? ""
                    
                    course.instructor = instructor
                    
                    print("Adding course \(course.promo)")
                    
                    courses += [course]
                    
                }
                completion(courses)
            }
        }
    }
 */
 
 
    func apply(user mail: String, to course: String, completion: @escaping () -> ()) {
        print("\n\n\nAplying \(mail) to the course \(course)...")
        
        let parameters = [
            "mail": mail,
            "promo": course
        ]
        
        let request = Alamofire.request("\(NetworkWorker.host)/apply", method: .post, parameters: parameters, encoding: JSONEncoding.default)
        
        print("Request Status Code: \(request.response?.statusCode)")
        
        print("Done. Running completion closure...")
        
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
        
        print("Done. Running completion closure...")
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
                
                print("Done. Running completion closure...")
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
        
        print("Done. Running completion closure...")

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
    
    func fetchStudents(for course: String, completion: @escaping () -> ()) {
        print("\n\n\nFetching students for course...")
        
        Alamofire.request("\(NetworkWorker.host)/students", parameters : ["promo": course]).responseJSON { response in
            if let JSONResponse = response.result.value {
                let json = JSON(JSONResponse)
                
                
            }
        }
    }
}
