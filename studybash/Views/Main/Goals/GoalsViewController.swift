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

class GoalsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var goalsCV: UICollectionView!
    let goalsCellIdentifier: String = "goal_cell"
    let db: Firestore = Firestore.firestore()
    let goalsTitles = ["1","2","3","4","5","6","7","8","9","10","11","12"]
    let userData: [String: Any] = [String: Any]()

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goalsTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = goalsCV.dequeueReusableCell(withReuseIdentifier: goalsCellIdentifier, for: indexPath) as! GoalsCollectionViewCell
        cell.goalName.text = goalsTitles[indexPath.row]
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

    func dbStuff() {

    }
}
