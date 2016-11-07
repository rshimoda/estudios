//
//  StartScreenViewController.swift
//  Estudios
//
//  Created by Sergey Popov on 9/23/16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

import UIKit
import QuartzCore

protocol StartScreenDelegate {
    var delegate: StartScreenViewController? { get set }
}

class StartScreenViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var textViewHolder: UIView!
    @IBOutlet weak var upperTextFieldHolder: UIView!
    
    let userValidator = UserValidator()
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
