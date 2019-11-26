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
import SwiftMessages



class SignupViewController: UIViewController {
    var auth: Auth = Auth.auth()
    let db: Firestore = Firestore.firestore()
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
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

        
        switch type {
        case "name":
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Missing First Name!", body: "Please enter your First Name", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
            
        case "lastName":
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Missing Last Name!", body: "Please enter your Last Name", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
            
        case "email":
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Missing Email!", body: "Please enter your email", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
            
        case "emailFormat":
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Invalid Email!", body: "Email address is not valid. Please try again", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
            
        case "emailExists":
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Invalid Email!", body: "Email address is already in use. Try resetting your password if you forgot it", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
            
        case "password":
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Missing password", body: "Please enter your password", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
            
        case "passConfirmation":
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Confirm Your Passwods", body: "Please confirm your password again", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
            
        case "mismatch":
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Password Mismatch!", body: "Your passwords did not match", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
            
        default:
            _ = ""
            _ = ""
        }


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
                ], completion: { _ in             self.db.collection("users").document(self.auth.currentUser!.uid).collection("goals").addDocument(data: [
                        "date_created": Timestamp(date: Date()),
                        "due_date": Timestamp(date: Date()),
                        "finished": false,
                        "name": "Your First Goal!",
                        "notes": "",
                        "statistics": [
                            "time_spent": 42
                        ],
                        "types": [
                            self.db.collection("goal_types").document("C4mCR1TM08fzLnsjBSFZ")
                        ],
                ], completion: { _ in self.dismiss(animated: true, completion: nil) })
                })
            })
        }
    }
}
