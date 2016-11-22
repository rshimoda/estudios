//
//  StartScreenViewController.swift
//  Estudios
//
//  Created by Sergey Popov on 9/23/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit
import QuartzCore
import ChameleonFramework

protocol StartScreenDelegate {
    var delegate: StartScreenViewController? { get set }
}

class StartScreenViewController: UIViewController, UITextFieldDelegate, CAAnimationDelegate {
    
    // MARK: - Properties
    
    var gradient: CAGradientLayer?
    @IBOutlet weak var logoImage: SpringImageView!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var textViewHolder: UIView!
    @IBOutlet weak var upperTextFieldHolder: UIView!
    @IBOutlet weak var accountCreationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var changeHostButton: UIButton!
    
    let userValidator = UserValidator()
    
    var startingGradientColors = [UIColor.flatNavyBlue().cgColor, UIColor.flatTeal().cgColor, UIColor.flatOrange().cgColor]
    var finalGradientColors = [UIColor.flatTeal().cgColor, UIColor.flatSkyBlueColorDark().cgColor, UIColor.flatYellowColorDark().cgColor]
    
    // MARK: - View loading
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set statusbar to be white
        self.setStatusBarStyle(UIStatusBarStyleContrast)
        
        // Set transparent background for buttons
        signInButton.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        accountCreationButton.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        changeHostButton.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        
        // Preparations for convenient work with keyboard
        mailTextField.delegate = self
        passwordTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        // Rounding and styling authorization field's borders
        textViewHolder.layer.cornerRadius = 10
        textViewHolder.layer.masksToBounds = true
        textViewHolder.layer.borderColor = UIColor.darkGray.cgColor
        textViewHolder.layer.borderWidth = 0.5
        upperTextFieldHolder.layer.borderColor = UIColor.darkGray.cgColor
        upperTextFieldHolder.layer.borderWidth = 0.5
        
        // Fetching all users from the DB
//        NetworkWorker.sharedInstance.fetchUsersData() { users in
//            for user in users {
//                DataHolder.sharedInstance.users[user.mail] = user
//            }
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Animate background gradient image
        self.gradient = CAGradientLayer()
        self.gradient!.frame = self.view.bounds
        self.gradient!.colors = startingGradientColors
        self.view.layer.insertSublayer(self.gradient!, at: 0)
        
        animateLayer()
    }
    
    func animateLayer(){
        
        let fromColors = startingGradientColors
        let toColors = finalGradientColors
        
        self.gradient!.colors = finalGradientColors
        
        let animation = CABasicAnimation(keyPath: "colors")
        
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = 7.00
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        
        self.gradient!.add(animation, forKey:"animateGradient")
    }
    
    //MARK: - Change Host
    @IBAction func changeHost() {
        signInButton.isHidden = true
        activityIndicator.startAnimating()
        
        let ac = UIAlertController(title: "Select Host", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "0.0.0.0:8080", style: .default, handler: { (action) -> Void in
            NetworkWorker.sharedInstance.host = "http://0.0.0.0:8080"
        }))
        ac.addAction(UIAlertAction(title: "10.0.1.7:8080", style: .default, handler: { (action) -> Void in
            NetworkWorker.sharedInstance.host = "http://10.0.1.7:8080"
        }))
        ac.addAction(UIAlertAction(title: "estudios-server", style: .default, handler: { (action) -> Void in
            NetworkWorker.sharedInstance.host = "https://estudios-server.herokuapp.com"
        }))
        ac.addAction(UIAlertAction(title: "Custom...", style: .default, handler: { (action) -> Void in
            self.setCustomHost()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
       
        present(ac, animated: true, completion: {(action) -> Void in
            self.activityIndicator.stopAnimating()
            self.signInButton.isHidden = false
        })
    }
    
    func setCustomHost() {
        let ac = UIAlertController(title: "Enter Host Adress", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "http://0.0.0.0:8080"
            textField.keyboardType = .numbersAndPunctuation
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            NetworkWorker.sharedInstance.host = ac.textFields!.first!.text ?? ""
        }))
        
        present(ac, animated: true, completion: { (action) -> Void in
            self.activityIndicator.stopAnimating()
            self.signInButton.isHidden = false
        })
    }
    
    // MARK: - CAAnimationDelegate
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.finalGradientColors = self.startingGradientColors;
            self.startingGradientColors = self.gradient?.colors as! [CGColor]
            
            animateLayer()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        
        if textField.isSecureTextEntry {
            signIn(signInButton)
        } else {
            self.passwordTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        signInButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        signInButton.isEnabled = !((mailTextField.text ?? "").isEmpty || (passwordTextField.text ?? "").isEmpty)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

    }
    
    // MARK: - Actions
    @IBAction func signIn(_ sender: UIButton) {
        
        signInButton.isHidden = true
        activityIndicator.startAnimating()
        
        NetworkWorker.sharedInstance.fetchUsersData { users in
            for user in users {
                DataHolder.sharedInstance.users[user.mail] = user
            }
            
            print("Fetching is finished. \n Recieved Users: ")
            debugPrint(DataHolder.sharedInstance.users)
            
            self.validateUserCredits()
        }
        
//        print("\n\n\nFetching Users...")
//        
//        Alamofire.request("\(NetworkWorker.sharedInstance.host)/users").responseJSON { response in
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
//                    DataHolder.sharedInstance.users[user.mail] = user
//                }
//            }
//            print("Fetching is finished. \n Recieved Users: ")
//            debugPrint(DataHolder.sharedInstance.users)
//            
//            self.validateUserCredits()
//            
//            self.activityIndicator.stopAnimating()
//            self.signInButton.isHidden = false
//        }
    }
    
    func validateUserCredits() {
        
        print("\n\n\nValidating Entered Values...")
        
        if UserValidator.validateUser(with: mailTextField.text ?? "", and: passwordTextField.text ?? "") {
            DataHolder.sharedInstance.user = UserValidator.getUser(with: mailTextField.text!, and: passwordTextField.text!)
            
            print("Validated.")
            
            // fetchCourses()
            NetworkWorker.sharedInstance.fetchCoursesData { courses in
                DataHolder.sharedInstance.courses.removeAll()

                print("Fetching is finished. Recieved Courses: ")
                debugPrint(DataHolder.sharedInstance.courses)
                
                for course in courses {
                    DataHolder.sharedInstance.courses += [course]
                }
                
                self.activityIndicator.stopAnimating()
                self.signInButton.isHidden = false
                
                self.performSegue(withIdentifier: "OpenCourseLibrary", sender: self)
            }
        } else {
            
            print("Validation Failed.")
            
            let ac = UIAlertController(title: "No such user", message: "The data you've entered seems not to corespond with existing user.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
//    func fetchCourses() {
//        
//        print("\n\n\nFetching Courses...")
//        
//        DataHolder.sharedInstance.courses.removeAll()
//
//        Alamofire.request("\(NetworkWorker.sharedInstance.host)/courses").responseJSON { response in
//
//            print("Original URL request: \(response.request)")
//            //print("HTTP URL response: \(response.response)")
//            print("Server data: \(response.data)")
//            print("Result of response serialization: \(response.result)")
//            
//            if let JSONResponse = response.result.value {
//                
//                let json = JSON(JSONResponse)
//                
//                print("JSON: ")
//                debugPrint(json)
//                
//                for (_,subJson):(String, JSON) in json {
//                    
//                    let courseJson = subJson["course"].dictionary!
//                    let studentsJson = subJson["students"].array!
//                    
//                    let course = Course(name: courseJson["name"]?.string ?? "", description: courseJson["description"]?.string ?? "", instructor: DataHolder.sharedInstance.users[(courseJson["instructor"]?.string!)!]!, promo: courseJson["promo"]?.string ?? "")
//                    course.duration = courseJson["duration"]?.string ?? ""
//                    course.level = courseJson["level"]?.string ?? ""
//                    course.type = courseJson["type"]?.string ?? ""
//                    
//                    for studentMail in studentsJson {
//                        if let user = DataHolder.sharedInstance.users[studentMail.string!] {
//                            course.students += [user]
//                        }
//                    }
//                    
//                    DataHolder.sharedInstance.courses += [course]
//                    //courses += [course]
//                    //self.prepare(course)
//                }
//            }
//            
//            print("Fetching is finished. Recieved Courses: ")
//            debugPrint(DataHolder.sharedInstance.courses)
//            
//            self.performSegue(withIdentifier: "OpenCourseLibrary", sender: self)
//        }
//    }
    
    @IBAction func iForgot(_ sender: UIButton) {
        let ac = UIAlertController(title: "Password Recovery", message: "We're hard at implementing this functionality.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
        
        present(ac, animated: true, completion: nil)
    }
    
    @IBAction func unwindToStartScreenAndLogOut(_ sender: UIStoryboardSegue) {
        DataHolder.sharedInstance.user = nil
    }

}
