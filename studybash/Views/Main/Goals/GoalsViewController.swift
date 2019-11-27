//
//  GoalsViewController.swift
//  studybash
//
//  Created by George Navarro on 10/12/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftyUserDefaults

let goalsCellIdentifier: String = "goal_cell"
var userDocRef: DocumentReference?

class GoalsViewController: UIViewController {
    @IBOutlet weak var goalsCV: UICollectionView!
    let db: Firestore = Firestore.firestore()
    let auth: Auth = Auth.auth()
    // All

    var userGoalsColRef: CollectionReference?
    var userGoalsData = [[String: Any]]()
    
    // Selected
    var selectedGoalData = [String: Any]()
    var selectedGoalListener: ListenerRegistration?
    var selectedGoalDocRef: DocumentReference?
    var selectedGoalSubGoals = [[String: Any]]()
    
    var goalTypes = [[String: Any]]()
    var goalDelegate: UpdateGoalData?
    var editMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(goalsCV)
        self.goalsCV.dataSource = self
        self.goalsCV.delegate = self
        userDocRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        self.userGoalsColRef = userDocRef?.collection("goals")
        let scheduleTab = self.tabBarController?.viewControllers![1] as! ScheduleViewController
        scheduleTab.userDocRef = userDocRef
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        self.goalsCV.addGestureRecognizer(longPressGR)
        
        getUserData()
        getGoalTypesListener()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goals_to_goal") {
            let vc = segue.destination as! GoalViewController
            goalDelegate = vc
            vc.userDocRef = userDocRef
            vc.goalTypes = goalTypes
            getSelectedGoalDataListener()
        } else if(segue.identifier == "goals_to_add_goal") {
            let vc = segue.destination as! AddEditGoalViewController
            vc.userDocRef = userDocRef
            vc.goalsColRef = userGoalsColRef!
            vc.goalTypes = goalTypes
            vc.useCase = "add_goal"
        } else if(segue.identifier == "goals_to_edit_goal") {
            let vc = segue.destination as! AddEditGoalViewController
            vc.userDocRef = userDocRef
            vc.goalTypes = goalTypes
            vc.goalData = selectedGoalData
            vc.useCase = "edit_goal"
        }
    }
    
    @objc
    func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .began {
            return
        }

        let point = longPressGR.location(in: self.goalsCV)
        let indexPath = self.goalsCV.indexPathForItem(at: point)

        if let indexPath = indexPath {
            // var cell = self.subGoalsTV.cellForRow(at: indexPath) // get cell at indexPath
            selectedGoalDocRef = userGoalsData[indexPath.row]["ref"] as? DocumentReference
            selectedGoalData = userGoalsData[indexPath.row]
            self.performSegue(withIdentifier: "goals_to_edit_goal", sender: self)
        }
    }
    
    func getSelectedGoalDataListener() {
        selectedGoalListener = self.selectedGoalDocRef!.collection("sub_goals").addSnapshotListener({(snapshot, error) in
            guard snapshot != nil else { print("Error:", error!); return }
            self.selectedGoalSubGoals = [[String: Any]]()
            snapshot!.documents.forEach({(subGoalDoc) in
                var subGoalData = subGoalDoc.data()
                subGoalData["ref"] = subGoalDoc.reference
                self.selectedGoalSubGoals.append(subGoalData)
            })
            self.goalDelegate?.updateGoalData(
                goalData: self.selectedGoalData,
                goalDocRef: self.selectedGoalDocRef!,
                subGoalsData: self.selectedGoalSubGoals)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if selectedGoalListener != nil {
            selectedGoalListener?.remove()
            selectedGoalListener = nil
        }
    }
    
    func getGoalTypesListener() {
        db.collection("goal_types").addSnapshotListener({ (snapshot, error) in
            guard snapshot != nil else { print("Error:", error!); return }
            self.goalTypes = [[String: Any]]()
            snapshot!.documents.forEach({ (doc) in
                var data = doc.data()
                data["ref"] = doc.reference
                self.goalTypes.append(data)
            })
        })
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
            self.userGoalsData = [[String: Any]]()
            goalDocRefs?.documents.forEach({ (doc) in
                var goalData = doc.data()
                goalData["ref"] = doc.reference
                self.userGoalsData.append(goalData)
                self.goalsCV.reloadData()
            })
        })
    }
    
    @IBAction func addNewGoalSegue(_ sender: Any) {
        self.performSegue(withIdentifier: "goals_to_add_goal", sender: self)
    }
    
}

extension GoalsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userGoalsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = goalsCV.dequeueReusableCell(withReuseIdentifier: goalsCellIdentifier, for: indexPath) as! GoalsCollectionViewCell
        cell.goalName.text = self.userGoalsData[indexPath.row]["name"] as? String
        cell.goalDocRef = self.userGoalsData[indexPath.row]["ref"] as? DocumentReference
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
        self.selectedGoalDocRef = self.userGoalsData[indexPath.row]["ref"] as? DocumentReference
        
        selectedGoalData = userGoalsData[indexPath.row]
        if !editMode {
            self.performSegue(withIdentifier: "goals_to_goal", sender: self)
        } else if editMode {
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
