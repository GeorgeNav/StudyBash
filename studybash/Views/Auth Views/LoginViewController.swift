//
//  LoginViewController.swift
//  studybash
//
//  Created by George Navarro on 10/11/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import NotificationCenter
import UserNotifications
import SwiftyUserDefaults
import Lottie
import SwiftMessages

class LoginViewController: UIViewController {
    var auth: Auth = Auth.auth()
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var email: String = ""
    var password: String = ""
    var isKeyboardAppear = false
    
    
    @IBOutlet weak var animationView: UIView!
    var animation : AnimationView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        emailTF.text = "george.g.navarro@gmail.com"
        passwordTF.text = "testing"
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if Defaults[.isLogin] == true {
            emailTF.text = Defaults[.email]
            passwordTF.text = Defaults[.password]
            signInButton(self)
        }
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
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Missing Email!", body: "Please enter your Email", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
        }
        else if (type == "password"){
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Missing Password!", body: "Please enter your password", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
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
            Defaults[.email] = email
            Defaults[.password] = password
            Defaults[.isLogin] = true
            
            guard authResult != nil else {
                let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
                messageView.configureBackgroundView(width: 300)
                messageView.configureContent(title: "Login Error!", body: "Your email or password is incorrect", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
                messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
                messageView.backgroundView.layer.cornerRadius = 10
                var config = SwiftMessages.defaultConfig
                config.presentationStyle = .center
                config.duration = .forever
                config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
                config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
                SwiftMessages.show(config: config, view: messageView)
                return
            }
            self.setupAnimation()
            DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
                self.performSegue(withIdentifier: "sign_in_to_goals", sender: self)
            })
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
    
    func setupAnimation() {
        animation = AnimationView(name: "loading")
        animation?.frame = animationView.bounds
        animationView.addSubview(animation!)
        animation?.loopMode = .loop
        animation?.contentMode = .scaleAspectFit
        animation?.play()
    }
}

extension DefaultsKeys {
    static let email = DefaultsKey<String?>("username")
    static let password = DefaultsKey<String?>("password")
    static let isLogin = DefaultsKey<Bool?>("isLogin")
}
