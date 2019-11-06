//
//  LoginViewController.swift
//  studybash
//
//  Created by George Navarro on 10/11/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import FirebaseAuth
import AuthenticationServices // Apple Login Auth.

class LoginViewController: UIViewController {
    var auth: Auth = Auth.auth()
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func signInButton(_ sender: Any) {
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
