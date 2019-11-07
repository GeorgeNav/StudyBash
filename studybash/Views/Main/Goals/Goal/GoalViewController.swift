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
    func updateGoalData(goalData: [String : Any], goalDocRef: DocumentReference, subGoalsData: [[String : Any]]) {
        self.subGoalsData = subGoalsData
        self.goalData = goalData
        self.goalDocRef = goalDocRef
        subGoalsTV.reloadData()
    }
    @IBOutlet weak var subGoalsTV: UITableView!
    var goalData: [String: Any] = [String: Any]()
    var subGoalsData: [[String: Any]] = [[String: Any]]()
    var goalDocRef: DocumentReference?
    var editMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subGoalsTV.dataSource = self
        self.subGoalsTV.delegate = self
        print(subGoalsData)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goal_to_add_goal" {
            let vc = segue.destination as! AddGoalViewController
            vc.goalsColRef = self.goalDocRef!.collection("sub_goals")
            vc.goalOrSubGoal = "sub_goal"
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func toggleEditMode(_ sender: Any) {
        editMode = !editMode
    }

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadData(subGoalsData: [[String: Any]]) {
        self.subGoalsData = subGoalsData
    }
    
    @IBAction func addSubGoalButton(_ sender: Any) {
        performSegue(withIdentifier: "goal_to_add_goal", sender: self)
    }
}

extension GoalViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subGoalsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = subGoalsTV.dequeueReusableCell(withIdentifier: subGoalCellIdentifier, for: indexPath) as! SubGoalsTableViewCell
        cell.subGoalName.text = subGoalsData[indexPath.row]["name"]! as? String
        cell.subGoalDocRef = subGoalsData[indexPath.row]["ref"] as? DocumentReference
        cell.deleteSubGoal.isHidden = !editMode
        cell.deleteSubGoal.isEnabled = editMode
        cell.deleteSubGoal.isUserInteractionEnabled = editMode
        cell.contentView.isUserInteractionEnabled = editMode
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let stopAction = UIContextualAction(style: .normal, title:  "Stop", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("Stop!")
            success(true)
        })
        stopAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [stopAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let startAction = UIContextualAction(style: .normal, title:  "Start", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("Start!")
            success(true)
        })
        startAction.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [startAction])
    }
    
}
