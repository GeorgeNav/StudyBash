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
    
    @IBAction func signUpButton(_ sender: Any) {
        guard emailTF.text?.count != 0 || passwordTF.text?.count != 0 else { return }
        let email = emailTF.text!
        let password = passwordTF.text!
        
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
