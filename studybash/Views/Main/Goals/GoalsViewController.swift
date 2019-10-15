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
        //uid = Auth.auth().currentUser!.uid
        uid = "schema"
        getUserData()
    }

    func getUserData() {
        db.collection("users").document(uid).collection("goals").getDocuments(completion: { (goalDocRefs, error) in
            goalDocRefs?.documents.forEach({ (doc) in
                let goalData = doc.data()
                self.allGoals.append(goalData["name"]! as! String)
                self.goalsCV.reloadData()
            })
        })
    
        //  subGoalsDueOnDate(date: Date())
    }
        
    func subGoalsDueOnDate(date:Date) {
        db.collection("users").document(uid).getDocument { (snapshot, error) in
            guard snapshot != nil else { print("Error:", error!); return }
            self.db.collectionGroup("sub_goals")
            .start(atDocument: snapshot!)
            .whereField("due_date", date: date)
            .getDocuments(completion: {(snapshot, error) in
                guard snapshot != nil else { print("Error:", error!); return }
                print(snapshot!.documents.count)
                snapshot?.documents.forEach({ (subGoalDocRef) in
                    print(subGoalDocRef.data()["name"]!)
                })
            })
        }
    }
}

extension Query {
    func whereField(_ field: String, date: Date) -> Query {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let start = dateFormatter.date(from: dateFormatter.string(from: date))!
        let end = dateFormatter.date(from: dateFormatter.string(from: date.dayAfter))!
        return whereField(field, isGreaterThanOrEqualTo: Timestamp(date: start)).whereField(field, isLessThan: Timestamp(date: end))
    }
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}
