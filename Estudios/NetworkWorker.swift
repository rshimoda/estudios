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
    static let sharedInstance = NetworkWorker()
    
    var host = "https://estudios-server.herokuapp.com" // "172.20.10.2"
    
    func fetchUsersData(completion: @escaping (_ storedUsers: [User]) -> ()) {
//        print("\n\n\nFetching Users...")
//        
//        Alamofire.request("\(host)/users").responseJSON { response in
//            
//            print("Original URL request: \(response.request)")
//            //print("HTTP URL response: \(response.response)")
//            print("Server data: \(response.data)")
//            print("Result of response serialization: \(response.result)")
//            
//            if let JSONResponse = response.result.value {
//                print("JSON: \(JSONResponse)")
//                
//                let json = JSON(JSONResponse)
//                var users = [User]()
//                
//                for (_,subJson):(String, JSON) in json {
//                    let user = User(id: subJson["id"].int ?? 0, mail: subJson["mail"].string ?? "", password: subJson["password"].string ?? "", firstName: subJson["firstname"].string ?? "", lastName: subJson["lastname"].string ?? "", isInstructor: subJson["isinstructor"].bool ?? false)
//                    users += [user]
//                    //DataHolder.sharedInstance.users[user.mail] = user
//                }
//                completion(users)
//            }
//        }
        print("\n\n\nFetching Users...")
        
        Alamofire.request("\(NetworkWorker.sharedInstance.host)/users").responseJSON { response in
            
            print("Original URL request: \(response.request)")
            //print("HTTP URL response: \(response.response)")
            print("Server data: \(response.data)")
            print("Result of response serialization: \(response.result)")
            
            if let JSONResponse = response.result.value {
                print("JSON: \(JSONResponse)")
                
                let json = JSON(JSONResponse)
                var users = [User]()
                
                for (_,subJson):(String, JSON) in json {
                    let user = User(id: subJson["id"].int ?? 0, mail: subJson["mail"].string ?? "", password: subJson["password"].string ?? "", firstName: subJson["firstname"].string ?? "", lastName: subJson["lastname"].string ?? "", isInstructor: subJson["isinstructor"].bool ?? false)
                    users += [user]
                    //DataHolder.sharedInstance.users[user.mail] = user
                }
                
                completion(users)
            }
            print("Fetching is finished. \n Recieved Users: ")
            debugPrint(DataHolder.sharedInstance.users)
        }
    }
    
    func fetchCoursesData(completion: @escaping (_ courses: ([Course])) -> Void) {
        
//        print("\n\n\nFetching Courses...")
//        DataHolder.sharedInstance.courses.removeAll()
//        
//        Alamofire.request("\(host)/courses").responseJSON { response in
//            
//            print("Original URL request: \(response.request)")
//            //print("HTTP URL response: \(response.response)")
//            print("Server data: \(response.data)")
//            print("Result of response serialization: \(response.result)")
//            
//            if let JSONResponse = response.result.value {
//                print("JSON: \(JSONResponse)")
//
//                let json = JSON(JSONResponse)
//                
//                for (_,subJson):(String, JSON) in json {
//                    let course = Course(name: subJson["name"].string ?? "", description: subJson["description"].string ?? "", instructor: DataHolder.sharedInstance.users[subJson["instructor"].string!]!, promo: subJson["promo"].string ?? "")
//                    course.duration = subJson["duration"].string ?? ""
//                    course.level = subJson["level"].string ?? ""
//                    course.type = subJson["type"].string ?? ""
//                    
//                    //DataHolder.sharedInstance.courses += [course]
//                    //courses += [course]
//                    completion(course)
//                }
//            }
//        }
        
        print("\n\n\nFetching Courses...")
        
        //DataHolder.sharedInstance.courses.removeAll()
        
        Alamofire.request("\(NetworkWorker.sharedInstance.host)/courses").responseJSON { response in
            
            print("Original URL request: \(response.request)")
            //print("HTTP URL response: \(response.response)")
            print("Server data: \(response.data)")
            print("Result of response serialization: \(response.result)")
            
            if let JSONResponse = response.result.value {
                
                let json = JSON(JSONResponse)
                var courses = [Course]()
                
                print("JSON: ")
                debugPrint(json)
                
                for (_,subJson):(String, JSON) in json {
                    
                    let courseJson = subJson["course"].dictionary!
                    let studentsJson = subJson["students"].array!
                    
                    let course = Course(name: courseJson["name"]?.string ?? "", description: courseJson["description"]?.string ?? "", instructor: DataHolder.sharedInstance.users[(courseJson["instructor"]?.string!)!]!, promo: courseJson["promo"]?.string ?? "")
                    course.duration = courseJson["duration"]?.string ?? ""
                    course.level = courseJson["level"]?.string ?? ""
                    course.type = courseJson["type"]?.string ?? ""
                    
                    for studentMail in studentsJson {
                        if let user = DataHolder.sharedInstance.users[studentMail.string!] {
                            course.students += [user]
                        }
                    }
                    
                    //DataHolder.sharedInstance.courses += [course]
                    courses += [course]
                    //self.prepare(course)
                }
                
                completion(courses)
            }
        }
    }
    
//    func fetchStudents(for course: Course, completion: @escaping (_ storedStudents: [User]) -> Void) {
//        print("\nFetching students in \(course.promo)...")
//        Alamofire.request("\(self.host)/usersincourse", parameters: ["promo": course.promo]).responseJSON { response in
//            
//            print("Original URL request: \(response.request)")
//            //print("HTTP URL response: \(response.response)")
//            print("Server data: \(response.data)")
//            print("Result of response serialization: \(response.result)")
//            
//            if let JSONResponse = response.result.value {
//                print("JSON: \(JSONResponse)")
//                
//                let json = JSON(JSONResponse)
//                var students = [User]()
//                
//                for (_,subJson):(String, JSON) in json {
//                    let user = DataHolder.sharedInstance.users[subJson["mail"].string!]!
//                    students += [user]
//                }
//                completion(students)
//            }
//        }
//    }
    
    func applyUser(with mail: String, to course: String) {
        print("\n\n\nAplying \(mail) to the course \(course)...")
        
        let request = Alamofire.request("\(host)/newUserInCourse", method: .post, parameters: [ "mail":"\(mail)", "promo": "\(course)" ], encoding: JSONEncoding.default)
        
        print("Request Status Code: \(request.response?.statusCode)")
    }
    
    func save(new course: Course) {
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
        let request = Alamofire.request("\(host)/newCourse", method: .post, parameters: parameters, encoding: JSONEncoding.default)

        print("Request Status Code: \(request.response?.statusCode)")
    }
    
    func save(new user: User) {
        print("\n\n\nSaving new user \(user.mail)...")
        
        let parameters: [String : Any] = [
            "mail": user.mail,
            "password": user.password,
            "firstname": user.firstName,
            "lastname": user.lastName,
            "isinstructor": user.isInstructor
        ]
        let request = Alamofire.request("\(host)/newUser", method: .post, parameters: parameters, encoding: JSONEncoding.default)
        
        print("Request Status Code: \(request.response?.statusCode)")
    }
}
