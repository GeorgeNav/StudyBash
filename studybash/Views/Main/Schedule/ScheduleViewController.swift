//  ScheduleViewController.swift
//  studybash
//  Created by Mustafa AL-Jaburi on 11/9/19.


import UIKit
import Firebase
import FSCalendar

class ScheduleViewController: UIViewController {
    let db: Firestore = Firestore.firestore()
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var subGoalsTV: UITableView!
    @IBOutlet weak var stopWatch: UILabel!
    
    var timer = Timer()
    var (hours, minutes, seconds, fractions) = (0,0,0,0)
    var totalSeconds = 0
    
    var calendarData = [String: Any]()
    var calendarDayListeners = [String: ListenerRegistration]()
    var currentMonthPos = -1
    
    var dispatchGroup: DispatchGroup?
    var studyBash: [String: Any]?
    
    var curDaySubGoalsData = [[String: Any]]()
    var currentDaySubGoalsListener: ListenerRegistration?
    var userDocRef: DocumentReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "schedule_cal_cell")
    }
    
    func subGoalsDueOnDate(date: Date) {
        var allSubGoalsDueThisDay = [String]()
        self.db.collectionGroup("sub_goals")
        .whereField("due_date", onThisDay: date)
        .whereField("uid_ref", isEqualTo: userDocRef!)
        .getDocuments(completion: { (snapshot, error) in
            guard snapshot != nil else { print(error!); return }
            snapshot?.documents.forEach({ (subGoalDocRef) in
                let subGoalData = subGoalDocRef.data()
                //print((subGoalData["due_date"]! as! Timestamp), " - ", subGoalData["name"]!, " - query")
                allSubGoalsDueThisDay.append(subGoalData["name"]! as! String)
            })
        })
    }
    
    func studyBashStop(subGoalDocRef: DocumentReference) {
        guard studyBash != nil else { return }
        studyBash!["stop"] = Timestamp(date: Date())
        
        // TODO: Perform math to calculate amount of seconds between start and stop times
        let start = studyBash!["start"]! as! Timestamp
        let stop = studyBash!["stop"]! as! Timestamp
        
        studyBash!["elapsed_time"] = stop.seconds - start.seconds
        print("Stop \(subGoalDocRef.documentID)! \(studyBash!["elapsed_time"]!) seconds")
        timer.invalidate()
        self.dispatchGroup?.enter()
        (studyBash!["ref"]! as! DocumentReference).getDocument { (snapshot, error) in
            guard snapshot != nil else { return }
            let thisSubGoalData = snapshot!.data()!
            var stats = thisSubGoalData["statistics"]! as! [String: Any]
            stats["time_spent"] = self.totalSeconds
            self.studyBash!.removeValue(forKey: "ref")
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
//        stopWatch.text = "00:00:00"
//        studyBashSubGoalName.text = subGoalData["name"]! as? String
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

extension ScheduleViewController: FSCalendarDataSource, FSCalendarDelegate {
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        if calendarData[dateFormat.string(from: date)] != nil { // Do something with the data
            curDaySubGoalsData = calendarData[dateFormat.string(from: date)]! as! [[String: Any]]
            print(curDaySubGoalsData)
            print(curDaySubGoalsData.count)
            subGoalsTV.reloadData()
        } else {
            curDaySubGoalsData = [[String: Any]]()
            subGoalsTV.reloadData()
        }
    }
    
    public func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "schedule_cal_cell", for: date, at: position)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        dateFormat.string(from: date)
        
        cell.imageView.contentMode = .scaleAspectFit
        if calendarDayListeners[dateFormat.string(from: date)] == nil {
            calendarDayListeners[dateFormat.string(from: date)] = db.collectionGroup("sub_goals")
            .whereField("due_date", onThisDay: date)
            .whereField("uid_ref", isEqualTo: userDocRef!)
            .addSnapshotListener({ (snapshot, error) in
                guard snapshot != nil || snapshot!.count == 0 else { return }
                var allSubGoalsDueThisDay = [[String: Any]]()
                snapshot!.documents.forEach({ (subGoalDocRef) in
                    var subGoalData = subGoalDocRef.data()
                    subGoalData["ref"] = subGoalDocRef.reference
                    //print((subGoalData["due_date"]! as! Timestamp), " - ", subGoalData["name"]!, " - query")
                    allSubGoalsDueThisDay.append(subGoalData)
                })
                self.calendarData[dateFormat.string(from: date)] = allSubGoalsDueThisDay
                self.calendar.reloadData()
                self.subGoalsTV.reloadData()
            })
        }
        
        return cell
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
        
        return whereField("due_date", isGreaterThanOrEqualTo: startTimestamp).whereField("due_date", isLessThan: endTimestamp)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return curDaySubGoalsData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = subGoalsTV.dequeueReusableCell(withIdentifier: subGoalCellIdentifier, for: indexPath) as! SubGoalsTableViewCell
        cell.subGoalName.text = curDaySubGoalsData[indexPath.row]["name"]! as? String
        cell.subGoalDocRef = curDaySubGoalsData[indexPath.row]["ref"] as? DocumentReference
        
        let notes = curDaySubGoalsData[indexPath.row]["notes"]! as? String
        cell.notesL.text = notes
        
        // TODO: Show category
        let typeRefs = curDaySubGoalsData[indexPath.row]["types"]! as!  [DocumentReference]
        if typeRefs.count != 0 {
            typeRefs[0].getDocument { (snapshot, error) in
                guard snapshot != nil else { return }
                let typeData = snapshot!.data()!
                cell.subType.text = typeData["name"]! as? String
            }
        }
        
        let stats = curDaySubGoalsData[indexPath.row]["statistics"]! as! [String: Any]
        let timeSpent = stats["time_spent"]! as! Double
        cell.hoursSpentL.text = "\(round(1000 * timeSpent/(60*60)) / 100)" + " Hours Spent"
        
        let dueDate = (curDaySubGoalsData[indexPath.row]["due_date"]! as! Timestamp).dateValue()
        let days = dueDate.days(sinceDate: Date())!
        if days == 0 { cell.daysLeftL.text = "Due Today" }
        else if days > 0 { cell.daysLeftL.text = "\(days) days left"
        } else if days < 0 {
            cell.daysLeftL.text = "\(abs(days)) Days Late"
            cell.daysLeftL.textColor = .red
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let stopAction = UIContextualAction(style: .normal, title:  "Stop", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let subGoalData = self.curDaySubGoalsData[indexPath.row]
            self.studyBashStop(subGoalDocRef: subGoalData["ref"]! as! DocumentReference)
            success(true)
        })
        stopAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [stopAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let startAction = UIContextualAction(style: .normal, title:  "Start", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let subGoalData = self.curDaySubGoalsData[indexPath.row]
            self.studyBashStart(
                subGoalDocRef: subGoalData["ref"]! as! DocumentReference,
                subGoalData: subGoalData
            )
            success(true)
        })
        startAction.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [startAction])
    }
    
}
