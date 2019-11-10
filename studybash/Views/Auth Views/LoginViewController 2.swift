//
//  LoginViewController.swift
//  studybash
//
//  Created by George Navarro on 10/11/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import FirebaseAuth
import NotificationCenter
import UserNotifications
import AuthenticationServices // Apple Login Auth.

class LoginViewController: UIViewController {
    var auth: Auth = Auth.auth()
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var email: String = ""
    var password: String = ""
    var isKeyboardAppear = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        emailTF.text = "george.g.navarro@gmail.com"
        passwordTF.text = "testing"
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardAppear {
            if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= 60
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
    
    func emptyFieldAlert(type: String) {
        if (type == "email"){
            let alert = UIAlertController(title: "Missing email", message: "Please enter your email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (type == "password"){
            let alert = UIAlertController(title: "Missing password", message: "Please enter your password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (type == "mismatch"){
            let alert = UIAlertController(title: "Login Error!", message: "Your email or password is incorrect ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func signInButton(_ sender: Any) {
        if (emailTF.text!.count > 0){
            email = emailTF.text!
        } else {
            emptyFieldAlert(type: "email")
            return
        }
        if (passwordTF.text!.count > 0){
            password = passwordTF.text!
        } else {
            emptyFieldAlert(type: "password")
            return
        }
        
        guard emailTF.text?.count != 0 || passwordTF.text?.count != 0 else { return }
        let email: String = emailTF.text!
        let password: String = passwordTF.text!
        
        auth.signIn(withEmail: email, password: password, completion: { (authResult, error) in
            guard authResult != nil else {
                print("Error: \(error!)")
                return
            }
            print(authResult!.user.email!, " is logged in!")
            self.performSegue(withIdentifier: "sign_in_to_goals", sender: self)
        })
    }
    
    
    @IBAction func signInWithAppleButton(_ sender: Any) {
    }
    
    func signInRelatedStuff() {
        //        auth.currentUser?.delete(completion: { (error) in
        //            guard error != nil else { return }
        //            print("Error: \(error!)")
        //        })
    }
    
}

