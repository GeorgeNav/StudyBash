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
    var allGoals: [String] = [String]()
    var uid: String = ""

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
        uid = Auth.auth().currentUser!.uid
        getUserData(uid: "schema")
    }

    func getUserData(uid:String) {
        db.collection("users").document(uid).collection("goals").getDocuments(completion: { (goalDocRefs, error) in
            goalDocRefs?.documents.forEach({ (doc) in
                let goalData = doc.data()
                self.allGoals.append(goalData["name"]! as! String)
                self.goalsCV.reloadData()
            })
        })
        
        //subGoalsDueOnDate(year: 2019, month: 10, day: 14)
    }
    
    func subGoalsDueOnDate(year:Int, month:Int, day: Int) {
        var allSubGoalsDueThisDay: [[String: Any]] = [[String: Any]]()
        
        db.collection("users").document(uid).collection("goals")
    }
}
