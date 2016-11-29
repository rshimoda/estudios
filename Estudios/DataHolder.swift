//
//  DataHolder.swift
//  Estudios
//
//  Created by Sergey Popov on 9/23/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import Foundation

class DataHolder {
    
    static let sharedInstance = DataHolder()
    
    var isAuthorized: Bool = false
    
    var currentUser: User!
    var currentCourse: Course!
    
    var currentManagedCourseList = [Course]()
    var currentCourseList = [Course]()
}
