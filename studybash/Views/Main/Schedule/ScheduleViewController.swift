//  ScheduleViewController.swift
//  studybash
//  Created by Mustafa AL-Jaburi on 11/9/19.


import UIKit
import Firebase
import FSCalendar

class ScheduleViewController: UIViewController {
    let db: Firestore = Firestore.firestore()
    @IBOutlet weak var calendar: FSCalendar!
    var calendarData = [String: Any]()
    var calendarDayListeners = [String: ListenerRegistration]()
    
    var currentMonthPos = -1
    
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
    
}

extension ScheduleViewController: FSCalendarDataSource, FSCalendarDelegate {
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        if calendarData[dateFormat.string(from: date)] != nil { // Do something with the data
            dump(calendarData[dateFormat.string(from: date)]!)
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
                    //print((subGoalData["due_date"]! as! Timestamp), " - ", subGoalData["name"]!, " - query")
                    allSubGoalsDueThisDay.append(subGoalDocRef.data())
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
