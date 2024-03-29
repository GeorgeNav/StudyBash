

import UIKit
import FirebaseFirestore
import Lottie
import UserNotifications
import NotificationCenter

let subGoalCellIdentifier = "sub_goal_cell"

protocol UpdateGoalData {
    func updateGoalData(goalData: [String : Any], goalDocRef: DocumentReference, subGoalsData: [[String : Any]])
}

class GoalViewController: UIViewController, UpdateGoalData {
    
    @IBOutlet weak var subGoalsTV: UITableView!
    @IBOutlet weak var goalNameL: UILabel!
    @IBOutlet weak var stopWatch: UILabel!
    @IBOutlet weak var studyBashSubGoalName: UILabel!
    var timer = Timer()
    
    var animation : AnimationView?
    var userDocRef: DocumentReference?
    var goalData = [String: Any]()
    var goalTypes = [[String: Any]]()
    var subGoalTypes = [[String: Any]]()
    var subGoalsData = [[String: Any]]()
    var goalDocRef: DocumentReference?
    var dispatchGroup: DispatchGroup?
    var studyBash: [String: Any]?
    var (hours, minutes, seconds, fractions) = (0,0,0,0)
    var totalSeconds = 0
    var selectedSubGoal = [String: Any]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.subGoalsTV.dataSource = self
        self.subGoalsTV.delegate = self
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.1
        longPressGR.delaysTouchesBegan = true
        self.subGoalsTV.addGestureRecognizer(longPressGR)
        //        subGoalsTV.rowHeight = UITableView.automaticDimension
        //        subGoalsTV.estimatedRowHeight = UITableView.automaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goal_to_add_sub_goal" {
            let vc = segue.destination as! AddEditGoalViewController
            vc.userDocRef = userDocRef
            vc.goalsColRef = self.goalDocRef!.collection("sub_goals")
            vc.goalTypes = subGoalTypes
            vc.useCase = "add_sub_goal"
        } else if segue.identifier == "goal_to_edit_sub_goal" {
            let vc = segue.destination as! AddEditGoalViewController
            vc.userDocRef = userDocRef
            vc.goalsColRef = self.goalDocRef!.collection("sub_goals")
            vc.goalData = selectedSubGoal
            vc.goalTypes = subGoalTypes
            vc.useCase = "edit_sub_goal"
        }
    }
    
    @objc
    func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .began {
            return
        }

        let point = longPressGR.location(in: self.subGoalsTV)
        let indexPath = self.subGoalsTV.indexPathForRow(at: point)

        if let indexPath = indexPath {
            // var cell = self.subGoalsTV.cellForRow(at: indexPath) // get cell at indexPath
            selectedSubGoal = subGoalsData[indexPath.row]
            self.performSegue(withIdentifier: "goal_to_edit_sub_goal", sender: self)
        }
    }
    
    func getSubGoalTypes() {
        var subGoalTypesRefs = [DocumentReference]()
        let thisGoalTypesRefs = goalData["types"]! as! [DocumentReference]
        subGoalTypes = [[String: Any]]()
        goalTypes.forEach { (typeData) in
            let typeDocRef = typeData["ref"]! as! DocumentReference
            guard thisGoalTypesRefs.contains(typeDocRef) else { return }
            let subTypesDocRefs = typeData["sub_types"]! as! [DocumentReference]
            subTypesDocRefs.forEach { (subTypeDocRef) in
                if !subGoalTypesRefs.contains(subTypeDocRef) {
                    subGoalTypesRefs.append(subTypeDocRef)
                }
            }
        }
        
        subGoalTypesRefs.forEach { (subGoalTypeRef) in
            subGoalTypeRef.getDocument { (snapshot, error) in
                guard snapshot != nil else { return }
                var subGoalTypeData = snapshot!.data()!
                subGoalTypeData["ref"] = snapshot!.reference
                self.subGoalTypes.append(subGoalTypeData)
                self.subGoalsTV.reloadData()
            }
        }
    }
    
    func updateGoalData(goalData: [String : Any], goalDocRef: DocumentReference, subGoalsData: [[String : Any]]) {
        self.subGoalsData = subGoalsData
        self.goalData = goalData
        self.goalDocRef = goalDocRef
        self.goalNameL?.text = goalData["name"]! as? String
        if subGoalTypes.count == 0 {
            getSubGoalTypes()
        }
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
        
        timer.invalidate()
        studyBash!["elapsed_time"] = self.totalSeconds
        print("Stop \(subGoalDocRef.documentID)! \(studyBash!["elapsed_time"]!) seconds")
        
        self.dispatchGroup?.enter()
        (studyBash!["ref"]! as! DocumentReference).getDocument { (snapshot, error) in
            guard snapshot != nil else { return }
            let thisSubGoalData = snapshot!.data()!
            var stats = thisSubGoalData["statistics"]! as! [String: Any]
            stats["time_spent"] = stats["time_spent"]! as! Int + self.totalSeconds
            self.studyBash!.removeValue(forKey: "ref")
            self.studyBash!.removeValue(forKey: "data")
            subGoalDocRef.updateData([
                "study_bashes": FieldValue.arrayUnion([self.studyBash!]),
                "statistics": stats
            ])
            self.studyBash = nil
            self.subGoalsTV.reloadData()
            self.dispatchGroup?.leave()
        }
    }
    
    func studyBashStart(subGoalDocRef: DocumentReference, subGoalData: [String: Any]) {
        guard studyBash == nil else { // Stop current studybash
            let studyBashDocRef = studyBash!["ref"]! as! DocumentReference
            guard studyBashDocRef != subGoalDocRef else { return }
            dispatchGroup = DispatchGroup()
            studyBashStop(subGoalDocRef: studyBashDocRef)
            dispatchGroup?.notify(queue: .main, execute: {
                self.studyBashStart(subGoalDocRef: subGoalDocRef, subGoalData: subGoalData)
                self.dispatchGroup = nil
            })
            return
        }
        
        print("Start \(subGoalDocRef.documentID)!")
        (hours, minutes, seconds, fractions) = (0, 0, 0, 0)
        totalSeconds = 0
        stopWatch.text = "00:00:00"
        studyBashSubGoalName.text = subGoalData["name"]! as? String
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setNewTime), userInfo: nil, repeats: true)
        studyBash = [
            "ref": subGoalDocRef,
            "start": Timestamp(date: Date()),
            "data": subGoalData
        ]
    }
    
    @objc func setNewTime() {
        totalSeconds += 1
        
        // Update UI
        seconds += 1
        if seconds == 60 {
            minutes += 1
            seconds = 0
        }
        if minutes == 60 {
            hours += 1
            minutes = 0
        }
        
        stopWatch.text =
            String(format: "%02d", hours) + " : " +
            String(format: "%02d", minutes) + " : " +
            String(format: "%02d", seconds)
    }
}

extension GoalViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.allowsSelection = false
        return subGoalsData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.allowsSelection = false
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.allowsSelection = false
        let cell = subGoalsTV.dequeueReusableCell(withIdentifier: subGoalCellIdentifier, for: indexPath) as! SubGoalsTableViewCell
        cell.subGoalName.text = subGoalsData[indexPath.row]["name"]! as? String
        cell.subGoalDocRef = subGoalsData[indexPath.row]["ref"] as? DocumentReference
        
        let notes = subGoalsData[indexPath.row]["notes"]! as? String
        cell.notesL.text = notes
        
        // TODO: Show category
        
        let stats = subGoalsData[indexPath.row]["statistics"]! as! [String: Any]
        let timeSpent = stats["time_spent"]! as! Double
        cell.hoursSpentL.text = "\(round(1000 * timeSpent/(60*60)) / 100)" + " Hours Spent"
        
        let dueDate = (subGoalsData[indexPath.row]["due_date"]! as! Timestamp).dateValue()
        let days = dueDate.days(sinceDate: Date())!
        if days == 0 { cell.daysLeftL.text = "Due Today" }
        else if days > 0 { cell.daysLeftL.text = "\(days) Days to due date"
        } else if days < 0 {
            cell.daysLeftL.text = "\(abs(days)) Days Late"
        }
        
        let thisSubGoalTypesRefs = subGoalsData[indexPath.row]["types"]! as! [DocumentReference]
        let thisSubGoalTypesData = subGoalTypes.filter { (subGoalTypeData) -> Bool in
            return thisSubGoalTypesRefs.contains(subGoalTypeData["ref"]! as! DocumentReference)
        }
        cell.subType.text = thisSubGoalTypesData.count > 0 ? thisSubGoalTypesData[0]["name"]! as! String : ""
        
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        let tf = DateFormatter()
        tf.dateFormat = "h:mm a"
        cell.dueDateL.text = "Due Date: " + df.string(from: dueDate) + "  " + tf.string(from: dueDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        tableView.allowsSelection = false
        let stopAction = UIContextualAction(style: .normal, title:  "Stop", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let subGoalData = self.subGoalsData[indexPath.row]
            self.studyBashStop(subGoalDocRef: subGoalData["ref"]! as! DocumentReference)
            success(true)
        })
        stopAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [stopAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        tableView.allowsSelection = false
        tableView.allowsSelection = false
        let startAction = UIContextualAction(style: .normal, title:  "Start", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let subGoalData = self.subGoalsData[indexPath.row]
            self.studyBashStart(
                subGoalDocRef: subGoalData["ref"]! as! DocumentReference,
                subGoalData: subGoalData
            )
            success(true)
        })
        startAction.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [startAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedSubGoal = subGoalsData[indexPath.row]
//        self.performSegue(withIdentifier: "goal_to_edit_sub_goal", sender: self)
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
