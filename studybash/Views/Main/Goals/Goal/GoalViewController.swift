//
//  GoalViewController.swift
//  studybash
//
//  Created by George Navarro on 10/17/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import FirebaseFirestore

let subGoalCellIdentifier = "sub_goal_cell"

protocol UpdateGoalData {
    func updateGoalData(goalData: [String : Any],
                        goalDocRef: DocumentReference,
                        subGoalsData: [[String : Any]])
}

class GoalViewController: UIViewController, UpdateGoalData {
    @IBOutlet weak var subGoalsTV: UITableView!
    @IBOutlet weak var goalNameL: UILabel!
    
    var goalData: [String: Any] = [String: Any]()
    var subGoalsData: [[String: Any]] = [[String: Any]]()
    var goalDocRef: DocumentReference?
    var studyBash: [String: Any]?
    var timer: Timer = Timer()
    var selectedSubGoalIndex: Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subGoalsTV.dataSource = self
        self.subGoalsTV.delegate = self
        subGoalsTV.rowHeight = UITableView.automaticDimension
        subGoalsTV.estimatedRowHeight = UITableView.automaticDimension
        print(subGoalsData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goal_to_add_sub_goal" {
            let vc = segue.destination as! AddEditGoalViewController
            vc.goalsColRef = self.goalDocRef!.collection("sub_goals")
            vc.useCase = "add_sub_goal"
        } else if segue.identifier == "goal_to_edit_sub_goal" {
            let vc = segue.destination as! AddEditGoalViewController
            vc.goalsColRef = self.goalDocRef!.collection("sub_goals")
            vc.goalData = subGoalsData[selectedSubGoalIndex]
            vc.useCase = "edit_sub_goal"
        } else {
            print("nope")
        }
    }
    
    func updateGoalData(goalData: [String : Any], goalDocRef: DocumentReference, subGoalsData: [[String : Any]]) {
        self.subGoalsData = subGoalsData
        self.goalData = goalData
        self.goalDocRef = goalDocRef
        self.goalNameL.text = goalData["name"]! as? String
        subGoalsTV.reloadData()
    }

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadData(subGoalsData: [[String: Any]]) {
        self.subGoalsData = subGoalsData
    }
    
    @IBAction func addSubGoalButton(_ sender: Any) {
        performSegue(withIdentifier: "goal_to_add_sub_goal", sender: self)
    }
    
    func studyBashStop(subGoalDocRef: DocumentReference) {
        guard studyBash != nil else { return }
        studyBash!["stop"] = Timestamp(date: Date())
        
        // TODO: Perform math to calculate amount of seconds between start and stop times
        let start = studyBash!["start"]! as! Timestamp
        let stop = studyBash!["stop"]! as! Timestamp
        studyBash!["elapsed_time"] = stop.seconds - start.seconds
        print("Stop \(subGoalDocRef.documentID)! \(studyBash!["elapsed_time"]!) seconds")
        studyBash!.removeValue(forKey: "ref")
        subGoalDocRef.updateData(["study_bashes": FieldValue.arrayUnion([studyBash!])])
        studyBash = nil
    }
    
    func studyBashStart(subGoalDocRef: DocumentReference) {
        guard studyBash == nil else { // Stop current studybash
            let studyBashDocRef = studyBash!["ref"]! as! DocumentReference
            if studyBashDocRef.documentID == subGoalDocRef.documentID { return }
            studyBashStop(subGoalDocRef: studyBashDocRef)
            studyBashStart(subGoalDocRef: subGoalDocRef)
            return
        }
        
        print("Start \(subGoalDocRef.documentID)!")
        studyBash = [
            "ref": subGoalDocRef,
            "start": Timestamp(date: Date())
        ]
    }
}

extension GoalViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subGoalsData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = subGoalsTV.dequeueReusableCell(withIdentifier: subGoalCellIdentifier, for: indexPath) as! SubGoalsTableViewCell
        cell.subGoalName.text = subGoalsData[indexPath.row]["name"]! as? String
        cell.subGoalDocRef = subGoalsData[indexPath.row]["ref"] as? DocumentReference
        
        let notes = subGoalsData[indexPath.row]["notes"]! as? String
        cell.notesL.text = notes
        
        // TODO: Show category
        
        let stats = subGoalsData[indexPath.row]["statistics"]! as! [String: Any]
        let timeSpent = stats["time_spent"]! as! Int
        cell.hoursSpentL.text = "\(timeSpent / 60)"
        
        let dueDate = (subGoalsData[indexPath.row]["due_date"]! as! Timestamp).dateValue()
        let days = dueDate.days(sinceDate: Date())!
        cell.daysLeftL.text = "\(days)"
        
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        let tf = DateFormatter()
        tf.dateFormat = "h:mm a"
        cell.dueDateL.text = df.string(from: dueDate) + "\n"
            + tf.string(from: dueDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let stopAction = UIContextualAction(style: .normal, title:  "Stop", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let subGoalData = self.subGoalsData[indexPath.row]
            self.studyBashStop(subGoalDocRef: subGoalData["ref"]! as! DocumentReference)
            success(true)
        })
        stopAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [stopAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let startAction = UIContextualAction(style: .normal, title:  "Start", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let subGoalData = self.subGoalsData[indexPath.row]
            self.studyBashStart(subGoalDocRef: subGoalData["ref"]! as! DocumentReference)
            success(true)
        })
        startAction.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [startAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSubGoalIndex = indexPath.row
        print("selected: \(subGoalsData[indexPath.row]["name"]!)")
        self.performSegue(withIdentifier: "goal_to_edit_sub_goal", sender: self)
    }
    
}

extension Date {

    func years(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.year], from: sinceDate, to: self).year
    }

    func months(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.month], from: sinceDate, to: self).month
    }

    func days(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.day], from: sinceDate, to: self).day
    }

    func hours(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.hour], from: sinceDate, to: self).hour
    }

    func minutes(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.minute], from: sinceDate, to: self).minute
    }

    func seconds(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.second], from: sinceDate, to: self).second
    }

}
