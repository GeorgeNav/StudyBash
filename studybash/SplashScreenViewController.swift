//
//  ViewController.swift
//  studybash
//
//  Created by George Navarro on 10/6/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
//import FirebaseDatabase
//import GoogleSignIn
import Lottie

class SplashScreenViewController: UIViewController {
    let db: Firestore! = Firestore.firestore()
    let auth: Auth! = Auth.auth()
    
    @IBOutlet weak var animationView: UIView!
    var animation : AnimationView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimation()
        //        db.collection("users").document("schema").getDocument() {(snapshot:DocumentSnapshot?, error:Error?) in
        //            guard snapshot != nil else { print("Error: \(error!)") ; return }
        //            print(snapshot!.data()!)
        //            let schemaRef: DocumentReference = snapshot!.data()!["goals"]! as! DocumentReference
        //            schemaRef.getDocument() {(snapshot, error) in
        //                guard snapshot != nil else { print("Error: \(error!)") ; return }
        //                print(snapshot!.data()!)
        //                let goalsArray = snapshot!.data()!["goals"]! as! [[String: Any]]
        //                let subGoalsRef = goalsArray[0]["sub_goals"]! as! DocumentReference
        //                subGoalsRef.getDocument() {(snapshot, error) in
        //                    guard snapshot != nil else { print("Error: \(error!)") ; return }
        //                    let subGoalsDic: [String: Any] = snapshot!.data()!
        //                    print(subGoalsDic)
        //                }
        //            }
        //        }
        let email = "goerge.g.navarro@gmail.com"
        let password = "ilikeiOS"
        //auth?.signIn(withEmail: email, password: password, completion: nil)
        //auth?.currentUser?.delete(completion: nil)
        auth?.createUser(withEmail: email, password: password, completion: nil)
        //auth?.currentUser?.sendEmailVerification(completion: nil)
    }
    
    func setupAnimation() {
        animation = AnimationView(name: "time")
        animation?.frame = animationView.bounds
        animationView.addSubview(animation!)
        animation?.loopMode = .loop
        animation?.contentMode = .scaleAspectFit
        animation?.play()
    }
    

}
