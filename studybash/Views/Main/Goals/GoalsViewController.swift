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
    var goalListener: ListenerRegistration?
    var goalTypesListener: ListenerRegistration?
    
    var selectedGoal = [String: Any]()
    var selectedGoalSubGoals = [[String: Any]]()
    var goalData = [[String: Any]]()
    var goalTypes = [[String: Any]]()
    var goalDelegate: UpdateGoalData?
    var editMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(goalsCV)
        goalsCV.dataSource = self
        goalsCV.delegate = self
        userGoalsColRef = db.collection("users").document(Auth.auth().currentUser!.uid).collection("goals")
        getUserData()
        getGoalTypesData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goals_to_goal") {
            let vc = segue.destination as! GoalViewController
            goalDelegate = vc
        } else if(segue.identifier == "goals_to_add_goal") {
            let vc = segue.destination as! AddEditGoalViewController
            vc.goalTypes = self.goalTypes
            vc.goalsColRef = self.userGoalsColRef!
            vc.useCase = "add_goal"
        } else if(segue.identifier == "goals_to_edit_goal") {
            let vc = segue.destination as! AddEditGoalViewController
            vc.goalData = selectedGoal
            vc.useCase = "edit_goal"
        }
    }
    
    @IBAction func toggleEditMode(_ sender: Any) {
        editMode = !editMode
        goalsCV.reloadData()
    }
    
    func getUserData() {
        guard userGoalsColRef != nil else { return }
        self.userGoalsColRef!.addSnapshotListener({ (goalDocRefs, error) in
            guard goalDocRefs != nil else { print("Error: ", error!); return }
            print("Number of Doc Changes: ", goalDocRefs!.documentChanges.count)
            self.goalData = [[String: Any]]()
            goalDocRefs?.documents.forEach({ (doc) in
                var goalData = doc.data()
                goalData["ref"] = doc.reference
                self.goalData.append(goalData)
                self.goalsCV.reloadData()
            })
        })
    }
    
    func getGoalTypesData() {
        goalTypesListener = db.collection("goal_types").addSnapshotListener({ (snapshot, error) in
            guard snapshot != nil else { print("Error:", error!); return }
            self.goalTypes = [[String: Any]]()
            snapshot!.documents.forEach({(doc) in
                var data = doc.data()
                data["ref"] = doc.reference
                self.goalTypes.append(data)
            })
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if goalListener != nil {
            goalListener?.remove()
            goalListener = nil
        }
    }
    
    @IBAction func addNewGoalSegue(_ sender: Any) {
        self.performSegue(withIdentifier: "goals_to_add_goal", sender: self)
    }
    
    func subGoalsDueOnDate(date: Date) {
        db.collection("users").document(Auth.auth().currentUser!.uid).addSnapshotListener({ (snapshot, error) in
            guard snapshot != nil else { print("Error:", error!); return }
            self.db.collectionGroup("sub_goals")
            .whereField("due_date", onThisDay: date)
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
        return goalData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = goalsCV.dequeueReusableCell(withReuseIdentifier: goalsCellIdentifier, for: indexPath) as! GoalsCollectionViewCell
        cell.goalName.text = self.goalData[indexPath.row]["name"] as? String
        cell.goalDocRef = self.goalData[indexPath.row]["ref"] as? DocumentReference
        cell.deleteGoal.isHidden = !editMode
        cell.deleteGoal.isEnabled = editMode
        cell.deleteGoal.isUserInteractionEnabled = editMode
        cell.contentView.isUserInteractionEnabled = editMode
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        return CGSize(width: screenSize.width/2.25, height: screenSize.width/2.25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedGoalDocRef = self.goalData[indexPath.row]["ref"]! as? DocumentReference
        
        if !editMode {
            self.performSegue(withIdentifier: "goals_to_goal", sender: self)
            goalListener = self.selectedGoalDocRef!.collection("sub_goals").addSnapshotListener({(snapshot, error) in
                guard snapshot != nil else { print("Error:", error!); return }
                self.selectedGoalSubGoals = [[String: Any]]()
                snapshot!.documents.forEach({(subGoalDoc) in
                    var subGoalData = subGoalDoc.data()
                    subGoalData["ref"] = subGoalDoc.reference
                    self.selectedGoalSubGoals.append(subGoalData)
                })
                self.goalDelegate?.updateGoalData(
                    goalData: self.selectedGoal,
                    goalDocRef: self.selectedGoalDocRef!,
                    subGoalsData: self.selectedGoalSubGoals)
            })
        } else if editMode {
            selectedGoal = goalData[indexPath.row]
            self.performSegue(withIdentifier: "goals_to_edit_goal", sender: self)
        }
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

