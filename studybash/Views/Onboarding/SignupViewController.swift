//
//  SignupViewController.swift
//  studybash
//
//  Created by George Navarro on 10/11/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {
    var auth: Auth = Auth.auth()
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
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
            self.performSegue(withIdentifier: "sign_in_success", sender: self)
            authResult!.user.sendEmailVerification(completion: { (_) in
                // Pop up to tell the user to check their email to verify their account
                self.dismiss(animated: true, completion: nil)
            })
        })
    }
}
