//  ScheduleViewController.swift
//  studybash
//  Created by Mustafa AL-Jaburi on 11/9/19.


import UIKit
import Firebase

class ScheduleViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let db: Firestore = Firestore.firestore()
    
    @IBOutlet weak var calendarCV: UICollectionView!
    @IBOutlet weak var monthL: UILabel!
    var subGoalsDataForMonths = [String: [String: Any]]()
    var subGoalsOnDayListener: ListenerRegistration?
    
    // Calendar
    let monthNames = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    let dayNames = ["Monday","Thuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var daysInMonths = [31,28,31,30,31,30,31,31,30,31,30,31]
    var currentMonth = ""
    var numNextMonthDays = -1
    var numCurMonthDays = -1
    var numPrevMonthDays = -1
    var curDirection = 0
    var positionIndex = 0
    var leapYearCounter = 2
    var dayCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentMonth = monthNames[curMonth]
        monthL.text = "\(currentMonth) \(curYear)"
        if curWeekday == 0 { curWeekday = 7 }
        getMonthDaysForDay()
    }
    
    func getSubGoalDataForSelectedMonth(date: Date) -> [[String: Any]] {
        var data = [[String: Any]]()
        return data
    }
    
    func subGoalsDueOnDate(date: Date) {
        if subGoalsOnDayListener != nil {
            subGoalsOnDayListener?.remove()
            subGoalsOnDayListener = nil
        }
        subGoalsOnDayListener = db.collection("users").document(Auth.auth().currentUser!.uid).addSnapshotListener({ (snapshot, error) in
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
    
    // Calculates the number of "empty" boxes at the start of every month"
    func getMonthDaysForDay() {
        switch curDirection {
        case 0:
            numCurMonthDays = curWeekday
            dayCounter = curDay
            while dayCounter > 0 {
                numCurMonthDays = numCurMonthDays - 1
                dayCounter = dayCounter - 1
                if numCurMonthDays == 0 { numCurMonthDays = 7 }
            }
            if numCurMonthDays == 7 { numCurMonthDays = 0 }
            positionIndex = numCurMonthDays
            
        case 1...:
            numNextMonthDays = (positionIndex + daysInMonths[curMonth]) % 7
            positionIndex = numNextMonthDays
            
        case -1:
            numPrevMonthDays = 7 - (daysInMonths[curMonth] - positionIndex) % 7
            if numPrevMonthDays == 7 { numPrevMonthDays = 0 }
            positionIndex = numPrevMonthDays
            
        default: fatalError()
        }
    }
    
    // next button
    @IBAction func next(_ sender: Any) {
        curDirection = 1
        
        switch currentMonth {
        case "December":
            curMonth = 0
            curYear += 1
            if leapYearCounter  < 5 { leapYearCounter += 1 }
            if leapYearCounter == 4 { daysInMonths[1] = 29 }
            if leapYearCounter == 5 {
                leapYearCounter = 1
                daysInMonths[1] = 28
            }
            getMonthDaysForDay()
            
        default:
            getMonthDaysForDay()
            curMonth += 1
        }
        currentMonth = monthNames[curMonth]
        monthL.text = "\(currentMonth) \(curYear)"
        calendarCV.reloadData()
    }
    
    // back button
    @IBAction func back(_ sender: Any) {
        curDirection = -1
        
        switch currentMonth {
        case "January":
            curMonth = 11
            curYear -= 1
            if leapYearCounter > 0 {
                leapYearCounter -= 1
            }
            if leapYearCounter == 0 {
                daysInMonths[1] = 29
                leapYearCounter = 4
            } else {
                daysInMonths[1] = 28
            }
            
        default:
            curMonth -= 1
        }
        
        getMonthDaysForDay()
        currentMonth = monthNames[curMonth]
        monthL.text = "\(currentMonth) \(curYear)"
        calendarCV.reloadData()
    }
    
    
    // CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch curDirection {
        case 0: return daysInMonths[curMonth] + numCurMonthDays
        case 1...: return daysInMonths[curMonth] + numNextMonthDays
        case -1: return daysInMonths[curMonth] + numPrevMonthDays
        default: fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Calendar", for: indexPath) as! DateCollectionViewCell
        cell.backgroundColor = UIColor.clear
        cell.dayL.textColor = UIColor.white
        cell.circleV.isHidden = true
        
        if cell.isHidden{ cell.isHidden = false }
        
        // the first cells that needs to be hidden (if needed) will be negative or zero so we can hide them
        var thisDay = -1
        switch curDirection {
        case 0: thisDay = indexPath.row + 1 - numCurMonthDays
        case 1: thisDay = indexPath.row + 1 - numNextMonthDays
        case -1: thisDay = indexPath.row + 1 - numPrevMonthDays
        default: fatalError()
        }
        cell.dayL.text = "\(thisDay)"
        
        // here we hide the negative numbers or zero
        if Int(cell.dayL.text!)! < 1 {
            cell.isHidden = true
            // TODO: Use this day
            if true {
                cell.circleV.isHidden = false
                cell.DrawCircle(progress: 1)
            }
        }
        
        // weekend days color
//        switch indexPath.row {
//        case 5,6,12,13,19,20,26,27,33,34:
//            if Int(cell.calDay.text!)! > 0 { cell.calDay.textColor = UIColor.darkGray }
//        default: break
//        }
        
//        if currentMonth == monthNames[Calendar.current.component(.month, from: curDate) - 1] && curYear == Calendar.current.component(.year, from: curDate) && indexPath.row + 1 - numCurMonthDays == curDay { // Do something on today's cell
//        }
        
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
        
        print(startTimestamp, " - start")
        print(endTimestamp, " - end")
        return whereField("due_date", isGreaterThanOrEqualTo: startTimestamp).whereField("due_date", isLessThan: endTimestamp)
    }
}
