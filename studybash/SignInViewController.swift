//
//  ViewController.swift
//  studybash
//
//  Created by George Navarro on 10/6/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseAuth
import FirebaseFirestore
//import FirebaseDatabase
//import GoogleSignIn
import Lottie

class SignInViewController: UIViewController {
    var db: Firestore! = Firestore.firestore()
    var userData = User()
    
    @IBOutlet weak var animationView: UIView!
    var animation : AnimationView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimation()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
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



struct User: Codable {
    let email: String
    let first_name: String
    let last_name: String
    let password: String
    init() {
        self.email = ""
        self.first_name = ""
        self.last_name = ""
        self.password = ""
    }
}
