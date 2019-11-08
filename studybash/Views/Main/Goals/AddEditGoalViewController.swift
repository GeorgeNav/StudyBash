//
//  AddGoalViewController.swift
//  studybash
//
//  Created by George Navarro on 10/15/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import FSCalendar
import FirebaseFirestore
import NotificationCenter
import UserNotifications

let typeCellIdentifier = "type_cell"

class AddEditGoalViewController: UIViewController {
    let db: Firestore = Firestore.firestore()
    
    // UI Elements
    fileprivate weak var calendar: FSCalendar!
    @IBOutlet weak var time: UIDatePicker!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var goalName: UITextField!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var notesTF: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var typesCV: UICollectionView!
    
    // Logic Elements
    var selectedDate: Date = Date()
    var typeNames: [String] = [String]()
    var filteredData: [String] = [String]()
    var goalsColRef: CollectionReference?
    var useCase: String = ""
    var goalData: [String: Any] = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredData = typeNames
        typesCV.delegate = self
        typesCV.dataSource = self
        searchBar.delegate = self
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cal_cell")
        view.addSubview(calendar)
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        calendar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        calendar.heightAnchor.constraint(equalToConstant: 275).isActive = true
        calendar.widthAnchor.constraint(equalToConstant: view.frame.width - 32).isActive = true
        calendar.backgroundColor = .white
        calendar.isHidden = true
        self.calendar = calendar
        
        let tab = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tab)
        
        if useCase == "add_goal" {
            titleL.text = "Add Goal"
            goalName.placeholder = "Goal Name"
            // TODO: hide notes and reminder
        } else if useCase == "add_sub_goal" {
            titleL.text = "Add Sub-goal"
            goalName.placeholder = "Sub-goal Name"
        } else if useCase == "edit_goal" || useCase == "edit_sub_goal" {
            let dueDate = (goalData["due_date"]! as! Timestamp).dateValue()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            dateButton.setTitle(dateFormatter.string(from: dueDate), for: .normal)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            timeButton.setTitle(timeFormatter.string(from: dueDate), for: .normal)
            
            titleL.text = "Goal"
            goalName.text = goalData["name"]! as? String
            
            time.date = dueDate
            self.calendar.select(dueDate)
            if useCase == "edit_goal" {
                // TODO: make UI different
            } else if useCase == "edit_sub_goal" {
                // TODO: make UI different
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addEditGoalButton(_ sender: Any) {
        print("trying to add/modify goal: \(useCase)")
        if useCase == "add_goal" || useCase == "add_sub_goal" {
            addGoal()
        } else if useCase == "edit_goal" || useCase == "edit_sub_goal" {
            editGoal()
        }
    }
    
    func addGoal() {
        goalData = [
            "date_created": Timestamp(date: Date()),
            "due_date": Timestamp(date: selectedDate),
            "finished": false,
            "name": goalName.text!,
            "statistics": [
                "time_spent": 42
            ],
            "types": [
                
            ]
        ]
        
        if useCase == "add_sub_goal" {
            goalData["notes"] =  notesTF.text!
            goalData["reminder"] = "" // TODO: get reminder data somehow
            goalData["study_bashes"] = []
        }
        
        self.goalsColRef!.addDocument(data: goalData)
        self.dismiss(animated: true, completion: nil)
    }
    
    func editGoal() {
        let goalDocRef = goalData.removeValue(forKey: "ref")! as! DocumentReference
        print("editing goal.. \(goalDocRef.documentID)")
        
        goalData["due_date"] = Timestamp(date: selectedDate)
        goalData["name"] = goalName.text!
        
        if useCase == "add_sub_goal" {
            goalData["notes"] =  notesTF.text!
            goalData["reminder"] = "" // TODO: get reminder data somehow
        }
        
        goalDocRef.updateData(goalData)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleCalendar(_ sender: Any) {
        calendar.isHidden = !calendar.isHidden
    }
    
    @IBAction func toggleTime(_ sender: Any) {
        time.isHidden = !time.isHidden
    }
    
    @IBAction func getTime(_ sender: Any) {
        print(time.date)
        let comp = Calendar.current.dateComponents([.hour, .minute], from: time.date)
        selectedDate = selectedDate.setTime(hour: comp.hour!, min: comp.minute!, sec: 0)!
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeButton.setTitle(timeFormatter.string(from: selectedDate), for: .normal)
    }
    

}

extension AddEditGoalViewController: FSCalendarDataSource, FSCalendarDelegate {
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate = date
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        self.dateButton.setTitle(dateFormat.string(from: date), for: .normal)
        calendar.isHidden = true
    }

    public func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cal_cell", for: date, at: position)
        cell.imageView.contentMode = .scaleAspectFit
        return cell
    }
}

extension AddEditGoalViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? typeNames : typeNames.filter { (item: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        typesCV.reloadData()
    }
}

extension AddEditGoalViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = typesCV.dequeueReusableCell(withReuseIdentifier: typeCellIdentifier, for: indexPath) as! AddGoalCollectionViewCell
        cell.type.tintColor = .cyan
        cell.type.setTitle(filteredData[indexPath.row], for: .normal)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        return CGSize(width: screenSize.width/4, height: 50)
    }
}

extension Date {
    public func setTime(hour: Int, min: Int, sec: Int, timeZoneAbbrev: String = "UTC") -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)

        components.timeZone = TimeZone(abbreviation: timeZoneAbbrev)
        components.hour = hour
        components.minute = min
        components.second = sec

        return cal.date(from: components)
    }
}


