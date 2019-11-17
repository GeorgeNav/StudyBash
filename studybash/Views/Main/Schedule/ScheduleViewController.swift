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
        subGoalsTV.delegate = self
        subGoalsTV.dataSource = self
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
                    subGoalData["ref"] = subGoalDocRef
                    //print((subGoalData["due_date"]! as! Timestamp), " - ", subGoalData["name"]!, " - query")
                    allSubGoalsDueThisDay.append(subGoalData)
                })
                self.calendarData[dateFormat.string(from: date)] = allSubGoalsDueThisDay
                calendar.reloadData()
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
        
        let thisSubGoalTypesRefs = curDaySubGoalsData[indexPath.row]["types"]! as! [DocumentReference]
        if thisSubGoalTypesRefs.count != 0 {
            cell.subType.text = thisSubGoalTypesRefs[0].documentID
        } else {
            cell.subType.text = ""
        }

        return cell
    }
    
}
