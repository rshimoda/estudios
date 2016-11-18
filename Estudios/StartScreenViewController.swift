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
    
    var gradient: CAGradientLayer?
    @IBOutlet weak var logoImage: SpringImageView!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var textViewHolder: UIView!
    @IBOutlet weak var upperTextFieldHolder: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let userValidator = UserValidator()
    
    var startingGradientColors = [UIColor.flatNavyBlue().cgColor, UIColor.flatTeal().cgColor, UIColor.flatOrange().cgColor] //[UIColor(red: 32.0, green: 27.0, blue: 28.0, alpha: 1.0).cgColor, UIColor(red: 199.0, green: 97.0, blue: 118.0, alpha: 1.0).cgColor] //[UIColor(red: 32.0, green: 27.0, blue: 28.0, alpha: 1.0).cgColor, UIColor(red: 34.0, green: 40.0, blue: 58.0, alpha: 1.0).cgColor, UIColor(red: 170.0, green: 53.0, blue: 3.0, alpha: 1.0).cgColor, UIColor(red: 199.0, green: 97.0, blue: 118.0, alpha: 1.0).cgColor]
    var finalGradientColors = [UIColor.flatTeal().cgColor, UIColor.flatOrange().cgColor, UIColor.flatLime().cgColor] // [UIColor(red: 34.0, green: 40.0, blue: 58.0, alpha: 1.0).cgColor, UIColor(red: 170.0, green: 53.0, blue: 3.0, alpha: 1.0).cgColor] //[UIColor(red: 34.0, green: 40.0, blue: 58.0, alpha: 1.0).cgColor, UIColor(red: 170.0, green: 53.0, blue: 3.0, alpha: 1.0).cgColor, UIColor(red: 34.0, green: 40.0, blue: 58.0, alpha: 1.0).cgColor, UIColor(red: 199.0, green: 97.0, blue: 128.0, alpha: 1.0).cgColor]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailTextField.delegate = self
        passwordTextField.delegate = self

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        
        textViewHolder.layer.cornerRadius = 10
        textViewHolder.layer.masksToBounds = true
        textViewHolder.layer.borderColor = UIColor.darkGray.cgColor
        textViewHolder.layer.borderWidth = 0.5
        
        upperTextFieldHolder.layer.borderColor = UIColor.darkGray.cgColor
        upperTextFieldHolder.layer.borderWidth = 0.5
    }

    override func viewWillAppear(_ animated: Bool) {
        let lImage = UIImage(named: "graduation")?.withRenderingMode(.alwaysTemplate)
        logoImage.image = lImage
        logoImage.alpha = 0.8
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    // CAAnimationDelegate
    
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
        if UserValidator.validateUser(with: mailTextField.text ?? "", and: passwordTextField.text ?? "") {
            DataHolder.sharedInstance.user = UserValidator.getUser(with: mailTextField.text!, and: passwordTextField.text!)
            performSegue(withIdentifier: "OpenCourseLibrary", sender: self)
        } else {
            let ac = UIAlertController(title: "No such user", message: "The data you've entered seems not to corespond with existing user.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    @IBAction func iForgot(_ sender: UIButton) {
        let ac = UIAlertController(title: "Password Recovery", message: "We're hard at implementing this functionality.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
        
        present(ac, animated: true, completion: nil)
    }

}
