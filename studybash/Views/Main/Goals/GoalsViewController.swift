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

let goalsCellIdentifier: String = "goal_cell"

class GoalsViewController: UIViewController {
    @IBOutlet weak var goalsCV: UICollectionView!
    
    let db: Firestore = Firestore.firestore()
    var userDocRef: DocumentReference?
    var userGoalsColRef: CollectionReference?
    var selectedGoalDocRef: DocumentReference?
    
    var selectedGoalSubGoals: [[String: Any]] = [[String: Any]]()
    var allGoalData: [[String: Any]] = [[String: Any]]()
    var allGoalNames: [String] = [String]()
    var goalTypeNames: [String] = [String]()
    var uid: String = ""
    var selectedGoalIndex: Int = 0
    var goalDelegate: UpdateGoalData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(goalsCV)
        self.goalsCV.dataSource = self
        self.goalsCV.delegate = self
        uid = Auth.auth().currentUser!.uid
        self.userGoalsColRef = db.collection("users").document(uid).collection("goals")
        getUserData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goals_to_goal") {
            let vc = segue.destination as! GoalViewController
            goalDelegate = vc
//            vc.goalData = self.allGoalData[selectedGoalIndex]
//            vc.subGoalsData = self.selectedGoalSubGoals
//            vc.goalDocRef = self.selectedGoalDocRef!
        } else if(segue.identifier == "goals_to_add_goal") {
            let vc = segue.destination as! AddGoalViewController
            vc.typeNames = self.goalTypeNames
            vc.goalsColRef = self.userGoalsColRef!
            vc.goalOrSubGoal = "goal"
        }
    }
    
    func getUserData() {
        guard userGoalsColRef != nil else { return }
        self.userGoalsColRef!.addSnapshotListener({ (goalDocRefs, error) in
            guard goalDocRefs != nil else { print("Error: ", error!); return }
            print("Number of Doc Changes: ", goalDocRefs!.documentChanges.count)
            self.allGoalNames = [String]() // make sure allGoals is emtpy before update from firestore
            goalDocRefs?.documents.forEach({ (doc) in
                var goalData = doc.data()
                goalData["ref"] = doc.reference
                self.allGoalData.append(goalData)
                self.allGoalNames.append(goalData["name"]! as! String)
                self.goalsCV.reloadData()
            })
        })
    }
    
    func goalSegue(withIdentifier identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
        self.selectedGoalDocRef!.collection("sub_goals").addSnapshotListener({(snapshot, error) in
            guard snapshot != nil else { print("Error:", error!); return }
            self.selectedGoalSubGoals = [[String: Any]]()
            snapshot!.documents.forEach({(subGoalDoc) in
                var subGoalData = subGoalDoc.data()
                subGoalData["ref"] = subGoalDoc.reference
                self.selectedGoalSubGoals.append(subGoalData)
            })
            self.goalDelegate?.updateGoalData(
                goalData: self.allGoalData[self.selectedGoalIndex],
                goalDocRef: self.selectedGoalDocRef!,
                subGoalsData: self.selectedGoalSubGoals)
        })
    }
    
    @IBAction func addNewGoalSegue(_ sender: Any) {
        db.collection("goal_types").getDocuments(completion: {(snapshot, error) in
            guard snapshot != nil else { print("Error:", error!); return }
            self.goalTypeNames = [String]()
            snapshot!.documents.forEach({(doc) in
                self.goalTypeNames.append(doc.data()["name"]! as! String)
            })
            self.performSegue(withIdentifier: "goals_to_add_goal", sender: self)
        })
    }
    
    func subGoalsDueOnDate(date: Date) {
        db.collection("users").document(uid).addSnapshotListener({ (snapshot, error) in
            guard snapshot != nil else { print("Error:", error!); return }
            self.db.collectionGroup("sub_goals")
            .whereField("due_date", onThisDay: date)
            .whereField("uid", isEqualTo: self.uid)
            .addSnapshotListener({ (snapshot, error) in
                guard snapshot != nil else { print("Error:", error!); return }
                print("Number of Doc Changes: ", snapshot!.documentChanges.count)
                print(snapshot!.documents.count)
                snapshot?.documents.forEach({ (subGoalDocRef) in
                    let subGoalData = subGoalDocRef.data()
                    print((subGoalData["due_date"]! as! Timestamp), " - ", subGoalData["name"]!, " - query")
                })
            })
        })
    }
}

extension GoalsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allGoalNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = goalsCV.dequeueReusableCell(withReuseIdentifier: goalsCellIdentifier, for: indexPath) as! GoalsCollectionViewCell
        cell.goalName.text = allGoalNames[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        return CGSize(width: screenSize.width/2.5, height: screenSize.width/2.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedGoalDocRef = self.allGoalData[indexPath.row]["ref"] as? DocumentReference
        goalSegue(withIdentifier: "goals_to_goal")
    }
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date { return Calendar.current.date(byAdding: .day, value: -1, to: noon)! }
    var dayAfter: Date { return Calendar.current.date(byAdding: .day, value: 1, to: noon)! }
    var noon: Date { return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)! }
    var month: Int { return Calendar.current.component(.month,  from: self) }
    var isLastDayOfMonth: Bool { return dayAfter.month != month }
    func convertToLocalTime(fromTimeZone timeZoneAbbreviation: String) -> Date? {
        if let timeZone = TimeZone(abbreviation: timeZoneAbbreviation) {
            let targetOffset = TimeInterval(timeZone.secondsFromGMT(for: self))
            let localOffeset = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT(for: self))

            return self.addingTimeInterval(targetOffset - localOffeset)
        }

        return nil
    }
}

extension Query {
    func whereField(_ field: String, onThisDay date: Date) -> Query {
        let f1 = DateFormatter()
        f1.dateFormat = "yyyy/MM/dd"
        let f2 = DateFormatter()
        f2.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let startDate = f2.date(from: f1.string(from: date) + " 00:00:00")!
        let endDate = f2.date(from: f1.string(from: date.dayAfter) + " 00:00:00")!
        let startTimestamp = Timestamp(date: startDate)
        let endTimestamp = Timestamp(date: endDate)
        
        print(startTimestamp, " - start")
        print(endTimestamp, " - end")
        return whereField("due_date", isGreaterThanOrEqualTo: startTimestamp).whereField("due_date", isLessThan: endTimestamp)
    }
}
