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
                    
                    Alamofire.request("https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=\(course.name)").responseJSON { response in
                        if let JSONResponse = response.result.value {
                            let json = JSON(JSONResponse)
                            
                            let resultsJSON = json["results"].array
                            let imageURL = resultsJSON?[0].dictionary?["unescapedUrl"]?.string
                            
                            do {
                                course.image = UIImage(data: try Data(contentsOf: URL(fileURLWithPath: imageURL ?? "")))
                            } catch {
                                print("Failed to load image to course")
                            }
                        }
                    }
                    
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
                    let courseDataJSON = managedCourseJSON["course"].dictionary!
                    let instructorDataJSON = managedCourseJSON["instructor"].dictionary!
                    let studentsJSON = managedCourseJSON["students"].array!
                    
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

                    
                    print("Adding managed course \(course.promo)")
                    
                    user.managedCourses += [course]
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
    
    func save(user: User, completion: @escaping () -> ()) {
        print("\n\n\nSaving new user \(user.mail)...")
        
        let parameters: [String : Any] = [
            "mail": user.mail,
            "password": user.password,
            "firstname": user.firstName,
            "lastname": user.lastName,
            "isinstructor": user.isInstructor
        ]
        let request = Alamofire.request("\(NetworkWorker.host)/new-user", method: .post, parameters: parameters, encoding: JSONEncoding.default)
        
        print("Request Status Code: \(request.response?.statusCode)")
        
        print("Done. Running completion closure...")
        completion()
    }
    
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
    
    func unroll(user: User, from course: String, completion: @escaping () -> ()) {
        print("\n\n\nUnrolling \(user.mail) from \(course)")
        
        let parameters = [
            "mail": user.mail,
            "promo": course
        ]
        
        Alamofire.request("\(NetworkWorker.host)/unroll", parameters: parameters).responseJSON { response in
            print(response.result.description)
        }
        
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
        
        let request = Alamofire.request("\(NetworkWorker.host)/new-course", method: .post, parameters: parameters, encoding: JSONEncoding.default)

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
        
        let request = Alamofire.request("\(NetworkWorker.host)/update-course", method: .post, parameters: parameters, encoding: JSONEncoding.default)
        
        print("Request Status Code: \(request.response?.statusCode)")
    }
    

    // MARK: - Topics
    
    func fetchTopics(for course: String, completion: @escaping ([Topic]) -> ()) {
        print("\n\n\nFetching \(course) Outline...")
        
        Alamofire.request("\(NetworkWorker.host)/topics", parameters: ["promo": course]).responseJSON { response in
            if let JSONResponse = response.result.value {
                let json = JSON(JSONResponse)
                
                var topics = [Topic]()
                
                for topicJSON in json {
                    let topic = Topic(promo: topicJSON.1["promo"].string ?? "", topicId: topicJSON.1["topicid"].string ?? "", name: topicJSON.1["name"].string ?? "")
                    topics.append(topic)
                    
                    print("Adding a new topic \(topic.name)")
                }
                
                completion(topics)
            }
        }
    }
    
    func save(topic: Topic, completion: @escaping () -> ()) {
        print("\n\n\nSaving new topic \(topic.name)...")
        
        let parameters = [
            "topicid": topic.topicId,
            "name": topic.name,
            "promo": topic.promo
        ]
        
        let request = Alamofire.request("\(NetworkWorker.host)/newTopic", method: .post, parameters: parameters, encoding: JSONEncoding.default)
        
        print("Request Status Code: \(request.response?.statusCode)")
        
        completion()
    }
    
    func delete(topic: Topic, completion: @escaping () -> ()) {
        print("\n\n\nDeleting topic \(topic.name)")
        
        let parameters = [
            "topicid": topic.topicId,
            "name": topic.name
        ]
        
        Alamofire.request("\(NetworkWorker.host)/delete-topic", parameters: parameters).responseJSON { response in
            print(response.result.description)
        }
        
        completion()
    }

}
