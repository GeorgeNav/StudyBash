//
//  LoginViewController.swift
//  studybash
//
//  Created by George Navarro on 10/11/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import FirebaseAuth

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
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
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
            self.performSegue(withIdentifier: "sign_in_success", sender: self)
        })
    }

    @IBAction func signInWithAppleButton(_ sender: Any) { // TODO: implement apple signin
        auth.currentUser?.delete(completion: { (error) in
            guard error == nil else { print("Error: \(error!)") ; return }
            print("DELETED USER")
        })
    }
    
    func signInRelatedStuff() {
//        auth.currentUser?.delete(completion: { (error) in
//            guard error != nil else { return }
//            print("Error: \(error!)")
//        })
    }
    
    func dbStuff() {
//        import Firebase
//        import FirebaseFirestore
//        let db: Firestore = Firestore.firestore()
//                db.collection("users").document("schema").getDocument() {(snapshot:DocumentSnapshot?, error:Error?) in
//                    guard snapshot != nil else { print("Error: \(error!)") ; return }
//                    print(snapshot!.data()!)
//                    let schemaRef: DocumentReference = snapshot!.data()!["goals"]! as! DocumentReference
//                    schemaRef.getDocument() {(snapshot, error) in
//                        guard snapshot != nil else { print("Error: \(error!)") ; return }
//                        print(snapshot!.data()!)
//                        let goalsArray = snapshot!.data()!["goals"]! as! [[String: Any]]
//                        let subGoalsRef = goalsArray[0]["sub_goals"]! as! DocumentReference
//                        subGoalsRef.getDocument() {(snapshot, error) in
//                            guard snapshot != nil else { print("Error: \(error!)") ; return }
//                            let subGoalsDic: [String: Any] = snapshot!.data()!
//                            print(subGoalsDic)
//                        }
//                    }
//                }
    }
}
