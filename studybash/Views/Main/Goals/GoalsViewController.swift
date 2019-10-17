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
    var selectedGoalSubGoals: [[String: Any]] = [[String: Any]]()
    var allGoalData: [[String: Any]] = [[String: Any]]()
    var allGoalNames: [String] = [String]()
    var uid: String = ""
    var selectedGoalIndex: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(goalsCV)
        self.goalsCV.dataSource = self
        self.goalsCV.delegate = self
        //uid = Auth.auth().currentUser!.uid
        uid = "schema"
        getUserData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goals_to_goal") {
            let vc = segue.destination as! GoalViewController
            vc.goalData = allGoalData[selectedGoalIndex]
            vc.subGoalsData = selectedGoalSubGoals
        }
    }
    
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
        selectedGoalIndex = indexPath.row
        customPerformSegue(withIdentifier: "goals_to_goal", goalName: allGoalNames[selectedGoalIndex])
    }

    func getUserData() {
        db.collection("users").document(uid).collection("goals").addSnapshotListener({ (goalDocRefs, error) in
            guard goalDocRefs != nil else { print("Error: ", error!); return }
            print("Number of Doc Changes: ", goalDocRefs!.documentChanges.count)
            self.allGoalNames = [String]() // make sure allGoals is emtpy before update from firestore
            goalDocRefs?.documents.forEach({ (doc) in
                var goalData = doc.data()
                goalData["doc_id"] = doc.documentID
                self.allGoalData.append(goalData)
                self.allGoalNames.append(goalData["name"]! as! String)
                self.goalsCV.reloadData()
            })
        })
        
        //subGoalsDueOnDate(date: Date())
    }
    
    func customPerformSegue(withIdentifier identifier:String, goalName:String) {
        db.collection("users").document(uid).collection("goals")
        .document(allGoalData[selectedGoalIndex]["doc_id"]! as! String)
        .collection("sub_goals").addSnapshotListener({(snapshot, error) in
            guard snapshot != nil else { print("Error:", error!); return }
            self.selectedGoalSubGoals = [[String: Any]]()
            snapshot!.documents.forEach({(doc) in
                self.selectedGoalSubGoals.append(doc.data())
            })
            self.performSegue(withIdentifier: identifier, sender: self)
        })
    }
    
    func subGoalsDueOnDate(date:Date) {
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
