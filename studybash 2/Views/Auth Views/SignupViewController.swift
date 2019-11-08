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
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passConfirmationTF: UITextField!
    
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    var passConfirmation = ""
    
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
    
    func emptyFieldAlert(type: String){
        if (type == "name"){
            let alert = UIAlertController(title: "Missing First Name", message: "Please enter your first name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (type == "lastName"){
            let alert = UIAlertController(title: "Missing Last Name", message: "Please enter your last name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (type == "email"){
            let alert = UIAlertController(title: "Missing email", message: "Please enter your email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (type == "password"){
            let alert = UIAlertController(title: "Missing password", message: "Please enter your password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (type == "passConfirmation"){
            let alert = UIAlertController(title: "Missing password confirmation", message: "Please enter your password again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (type == "mismatch"){
            let alert = UIAlertController(title: "Password Mismatch!", message: "Your passwords did not match. Check for typos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func signUpButton(_ sender: Any) {
        
        if (firstNameTF.text!.count > 0){
            firstName = firstNameTF.text!
        }
        else {
            emptyFieldAlert(type: "name")
            return
        }
        
        if (lastNameTF.text!.count > 0){
            lastName = lastNameTF.text!
        }
        else {
            emptyFieldAlert(type: "lastName")
            return
        }
        
        if (emailTF.text!.count > 0){
            email = emailTF.text!
        }
        else {
            emptyFieldAlert(type: "email")
            return
        }
        
        if (passwordTF.text!.count > 0){
            password = passwordTF.text!
        }
        else {
            emptyFieldAlert(type: "password")
            return
        }
        
        if (passConfirmationTF.text!.count > 0){
            passConfirmation = passConfirmationTF.text!
        }
        else {
            emptyFieldAlert(type: "passConfirmation")
            return
        }
        
        let validPass: Bool = ((password.count > 0 && passConfirmation.count > 0) && (password == passConfirmation))
        
        if (!validPass){
            emptyFieldAlert(type: "mismatch")
            return
        }
        
        if (firstName.count > 0 && lastName.count > 0 && email.count > 0 && validPass){
            auth.createUser(withEmail: email, password: password, completion: { (authResult, error) in
                guard authResult != nil else {
                    print("Error: \(error!)")
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
                    "phone_number": "",
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
