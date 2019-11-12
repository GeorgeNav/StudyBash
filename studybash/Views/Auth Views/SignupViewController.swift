//
//  SignupViewController.swift
//  studybash
//
//  Created by George Navarro on 10/11/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import UserNotifications
import NotificationCenter


class SignupViewController: UIViewController {
    var auth: Auth = Auth.auth()
    let db: Firestore = Firestore.firestore()
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passConfirmationTF: UITextField!
    
    var isKeyboardAppear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardAppear {
            if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= 40
                }
            }
            isKeyboardAppear = true
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if isKeyboardAppear {
            if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                if self.view.frame.origin.y != 0{
                    self.view.frame.origin.y = 0
                }
            }
             isKeyboardAppear = false
        }
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func returnToSignInButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createTextFieldAlert(type: String) {
        var title = ""
        var message = ""
        
        switch type {
        case "name":
            title = "Missing First Name"
            message = "Please enter your first name"
        case "lastName":
            title = "Missing Last Name"
            message = "Please enter your last name"
        case "email":
            title = "Missing Email"
            message = "Please enter your email"
        case "emailFormat":
            title = "Invalid Email"
            message = "Email address is not valid. Please try again"
        case "emailExists":
            title = "Invalid Email"
            message = "Email address is already in use. Try resetting your password if you forgot it."
        case "password":
            title = "Missing password"
            message = "Please enter your password"
        case "passConfirmation":
            title = "Missing password confirmation"
            message = "Please enter your password again"
        case "mismatch":
            title = "Password Mismatch"
            message = "Your passwords did not match. Check for typos"
        default:
            title = ""
            message = ""
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func signUpButton(_ sender: Any) {
        guard firstNameTF.text!.count > 0 else { createTextFieldAlert(type: "name"); return }
        guard lastNameTF.text!.count > 0 else { createTextFieldAlert(type: "lastName"); return }
        guard emailTF.text!.count > 0 else { createTextFieldAlert(type: "email"); return }
        guard passwordTF.text!.count > 0 else { createTextFieldAlert(type: "password"); return }
        guard passConfirmationTF.text!.count > 0 else { createTextFieldAlert(type: "passConfirmation"); return }
        let validPass: Bool = ((passwordTF.text!.count > 0 && passConfirmationTF.text!.count > 0) && (passwordTF.text! == passConfirmationTF.text!))
        guard validPass else { createTextFieldAlert(type: "mismatch"); return }
        
        if (firstNameTF.text!.count > 0 && lastNameTF.text!.count > 0 && emailTF.text!.count > 0 && validPass){
            auth.createUser(withEmail: emailTF.text!, password: passwordTF.text!, completion: { (authResult, error) in
                guard authResult != nil else {
                    print("Error: \(error!)")
                    if(error!.localizedDescription == "The email address is badly formatted."){
                        self.createTextFieldAlert(type: "emailFormat")
                    }
                    else if(error!.localizedDescription == "The email address is already in use by another account."){
                        self.createTextFieldAlert(type: "emailExists")
                    }
                    return
                }
                
                print(authResult!.user.email!, " account is created and logged in!")
                authResult!.user.sendEmailVerification(completion: { (_) in
                    // Decide if there needs to be a pop up to tell the user to check their email to verify their account
                })
                
                self.db.collection("users").document(self.auth.currentUser!.uid).setData([
                    "email": self.emailTF.text!,
                    "first_name": self.firstNameTF.text!,
                    "last_name": self.lastNameTF.text!,
                    "phone_number": self.phoneNumberTF.text!,
                ], completion: { _ in             self.db.collection("users").document(self.auth.currentUser!.uid).collection("goals").addDocument(data: [
                        "date_created": Timestamp(date: Date()),
                        "finished": false,
                        "name": "Your First Goal!",
                        "statistics": [
                            "time_spent": 42
                        ],
                        "types": [
                            self.db.collection("goal_types").document("C4mCR1TM08fzLnsjBSFZ")
                        ]
                ], completion: { _ in self.dismiss(animated: true, completion: nil) })
                })
            })
        }
    }
}
