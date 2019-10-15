//
//  GoalsViewController.swift
//  studybash
//
//  Created by George Navarro on 10/12/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

struct UserData {
    var info: [String: Any]
    var goals: [String: Any]
    
    init() {
        info = ["":""]
        goals = ["":""]
    }

    init(info i:[String: Any], goals g:[String: Any]) {
        info = i
        goals = g
    }
}

class GoalsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var goalsCV: UICollectionView!
    let goalsCellIdentifier: String = "goal_cell"
    let db: Firestore = Firestore.firestore()
    var allGoals: [String] = [String]()
    var ud: UserData = UserData()

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allGoals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = goalsCV.dequeueReusableCell(withReuseIdentifier: goalsCellIdentifier, for: indexPath) as! GoalsCollectionViewCell
        cell.goalName.text = allGoals[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        return CGSize(width: screenSize.width/2.5, height: screenSize.width/2.5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(goalsCV)
        self.goalsCV.dataSource = self
        self.goalsCV.delegate = self
        
        getUserData(uid: "schema")
    }

    func getUserData(uid:String) {
        var info: [String: Any] = [String: Any]()
        var goals: [String: Any] = [String: Any]()
        db.collection("users").document(uid).getDocument() {(snapshot:DocumentSnapshot?, error:Error?) in
            guard snapshot != nil else { print("Error: \(error!)") ; return }
            info = snapshot!.data()!
            let schemaRef: DocumentReference = snapshot!.data()!["goals"]! as! DocumentReference
            schemaRef.getDocument() {(snapshot, error) in
                guard snapshot != nil else { print("Error: \(error!)") ; return }
                goals = snapshot!.data()!
                self.ud = UserData(info: info, goals: goals)
                print(self.ud.info)
                print(self.ud.goals)
                self.ud.goals.forEach({(goalKey, goalData) in
                    let gd = goalData as! [String: Any]
                    self.allGoals.append(gd["name"]! as! String)
                })
                self.goalsCV.reloadData()
                print(Array(self.ud.goals.keys))
                print(self.allGoals)
//                let goalsArray = snapshot!.data()!["goals"]! as! [[String: Any]]
//                let subGoalsRef = goalsArray[0]["sub_goals"]! as! DocumentReference
//                subGoalsRef.getDocument() {(snapshot, error) in
//                    guard snapshot != nil else { print("Error: \(error!)") ; return }
//                    let subGoalsDic: [String: Any] = snapshot!.data()!
//                    print(subGoalsDic)
//                }
            }
        }
    }
}
