//  ScheduleViewController.swift
//  studybash
//  Created by Mustafa AL-Jaburi on 11/9/19.


import UIKit
import Firebase
import FSCalendar

class ScheduleViewController: UIViewController {
    let db: Firestore = Firestore.firestore()
    @IBOutlet weak var calendar: FSCalendar!
    var currentMonthPos = -1
    
    var subGoalsDataForMonths = [String: [String: Any]]()
    var currentDaySubGoalsListener: ListenerRegistration?
    var userDocRef: DocumentReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "schedule_cal_cell")
    }
    
    func subGoalsDueOnDate(date: Date) {
        
        self.db.collectionGroup("sub_goals")
        .whereField("due_date", onThisDay: date)
        .whereField("uid_ref", isEqualTo: userDocRef!)
        .getDocuments(completion: { (snapshot, error) in
            guard snapshot != nil else { print(error!); return }
            var allSubGoals = [String]()
            snapshot?.documents.forEach({ (subGoalDocRef) in
                let subGoalData = subGoalDocRef.data()
                //print((subGoalData["due_date"]! as! Timestamp), " - ", subGoalData["name"]!, " - query")
                allSubGoals.append(subGoalData["name"]! as! String)
            })
            print(allSubGoals)
        })
    }
    
}

extension ScheduleViewController: FSCalendarDataSource, FSCalendarDelegate {
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let f2 = DateFormatter()
        f2.dateFormat = "MM/dd/yyyy HH:mm:ss"
        print(f2.string(from: date))
        subGoalsDueOnDate(date: date)
    }
    
    public func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "schedule_cal_cell", for: date, at: position)
        cell.imageView.contentMode = .scaleAspectFit
        
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

/*
 @IBOutlet weak var circleV: UIView!
 
 func DrawCircle(progress: Double) {
     guard progress >= 0 && progress <= 1 else { return }
     
     let circleCenter = circleV.center
     
     let circlePath = UIBezierPath(arcCenter: circleCenter, radius: (circleV.bounds.width/2 - 5), startAngle: -CGFloat.pi/2, endAngle: (2 * CGFloat.pi), clockwise: true)
     
     let CircleLayer = CAShapeLayer()
     CircleLayer.path = circlePath.cgPath
     CircleLayer.strokeColor = UIColor.red.cgColor
     CircleLayer.lineWidth = 2
     CircleLayer.strokeEnd = 0
     CircleLayer.fillColor = UIColor.clear.cgColor
     CircleLayer.lineCap = CAShapeLayerLineCap.round
     
     let Animation = CABasicAnimation(keyPath: "strokeEnd")
     Animation.duration = 1
     Animation.toValue = progress
     Animation.fillMode = CAMediaTimingFillMode.forwards
     Animation.isRemovedOnCompletion = false
     
     CircleLayer.add(Animation, forKey: nil)
     circleV.layer.addSublayer(CircleLayer)
     circleV.layer.backgroundColor = UIColor.clear.cgColor
 }
 */
