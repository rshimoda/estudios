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
    
    let networkWorker = NetworkWorker()
    
    var startingGradientColors = [UIColor.flatNavyBlueColorDark().cgColor, UIColor.flatNavyBlue().cgColor, UIColor.flatTealColorDark().cgColor, UIColor.flatOrange().cgColor]
    var finalGradientColors = [UIColor.flatTealColorDark().cgColor, UIColor.flatSkyBlue().cgColor, UIColor.flatYellowColorDark().cgColor, UIColor.flatOrange().cgColor]
    
    // MARK: - View Controller

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
        animation.duration = 15.00
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        
        self.gradient!.add(animation, forKey:"animateGradient")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: - Change Host
    
    @IBAction func changeHost() {
        signInButton.isHidden = true
        activityIndicator.startAnimating()
        
        let ac = UIAlertController(title: "Select Host", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "localhost:8080", style: .default, handler: { (action) -> Void in
            NetworkWorker.host = "http://localhost:8080"
        }))
        ac.addAction(UIAlertAction(title: "10.0.1.7:8080", style: .default, handler: { (action) -> Void in
            NetworkWorker.host = "http://10.0.1.7:8080"
        }))
        ac.addAction(UIAlertAction(title: "estudios-server", style: .default, handler: { (action) -> Void in
            NetworkWorker.host = "https://estudios-server.herokuapp.com"
        }))
        ac.addAction(UIAlertAction(title: "Custom...", style: .default, handler: { [weak self] (action) -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.setCustomHost()
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
            NetworkWorker.host = ac.textFields!.first!.text ?? ""
        }))
        
        present(ac, animated: true, completion: { [weak self] (action) -> Void  in
            guard let strongSelf = self else {
                return
            }
            strongSelf.activityIndicator.stopAnimating()
            strongSelf.signInButton.isHidden = false
        })
    }
    
    // MARK: - Animation Delegate
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.finalGradientColors = self.startingGradientColors;
            self.startingGradientColors = self.gradient?.colors as! [CGColor]
            
            animateLayer()
        }
    }
    
    // MARK: - Text Field Delegate
    
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
    
    // MARK: - Authorization
    
    @IBAction func signIn(_ sender: UIButton) {
        
        signInButton.isHidden = true
        activityIndicator.startAnimating()
        
        debugPrint("\n\n\nValidating Entered Values...")
        
        if let mail = mailTextField.text, let password = passwordTextField.text {
            networkWorker.validate(user: mail, with: password) { [weak self] wasFound in
                guard let strongSelf = self else {
                    return
                }
                
                if wasFound {
                    debugPrint("Validated")
                    
                    strongSelf.networkWorker.get(user: mail) { user in
                        DataHolder.sharedInstance.currentUser = user
                        DataHolder.sharedInstance.isAuthorized = true
                        
                        strongSelf.activityIndicator.stopAnimating()
                        strongSelf.signInButton.isHidden = false
                        
                        strongSelf.performSegue(withIdentifier: "OpenCourseLibrary", sender: self)
                    }
                } else {
                    debugPrint("Validation failed")
                    
                    let ac = UIAlertController(title: "Authorization Failed", message: "No such user or problems with Internet connection", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: nil))
                    
                    strongSelf.activityIndicator.stopAnimating()
                    strongSelf.signInButton.isHidden = false
                    
                    strongSelf.present(ac, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Registration
    
    @IBAction func iForgot(_ sender: UIButton) {
        let ac = UIAlertController(title: "Password Recovery", message: "We're hard at implementing this functionality.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
        
        present(ac, animated: true, completion: nil)
    }
    
    // MARK: - Unwind Segues
    
    @IBAction func unwindToStartScreenAndLogOut(_ sender: UIStoryboardSegue) {
        DataHolder.sharedInstance.isAuthorized = false
    }
    
    @IBAction func unvindToStartScreen(sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func unvindToStartScreenAndRegister(_ sender: UIStoryboardSegue) {
        signInButton.isHidden = true
        activityIndicator.startAnimating()
        
        networkWorker.save(user: DataHolder.sharedInstance.currentUser) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.activityIndicator.stopAnimating()
            strongSelf.signInButton.isHidden = false
        }
    }
}
