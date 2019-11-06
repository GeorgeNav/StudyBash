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

let typeCellIdentifier = "type_cell"

class AddGoalViewController: UIViewController {
    let db: Firestore = Firestore.firestore()
    fileprivate weak var calendar: FSCalendar!
    @IBOutlet weak var time: UIDatePicker!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var goalName: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notesTF: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var typesCV: UICollectionView!
    var selectedDate: Date = Date()
    var typeNames = ["New York, NY", "Los Angeles, CA", "Chicago, IL", "Houston, TX",
    "Philadelphia, PA", "Phoenix, AZ", "San Diego, CA", "San Antonio, TX",
    "Dallas, TX", "Detroit, MI", "San Jose, CA", "Indianapolis, IN",
    "Jacksonville, FL", "San Francisco, CA", "Columbus, OH", "Austin, TX",
    "Memphis, TN", "Baltimore, MD", "Charlotte, ND", "Fort Worth, TX"]
    var filteredData: [String] = [String]()
    var goalsColRef: CollectionReference? // can be a goal or subgoal reference
    var goalOrSubGoal: String = ""
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if goalOrSubGoal == "goal" {
            titleLabel.text = "Add Goal"
            goalName.text = nil
            goalName.placeholder = "Goal Name"
            // TODO: hide notes and reminder
        } else if goalOrSubGoal == "sub_goal" {
            titleLabel.text = "Add Sub-goal"
            goalName.text = nil
            goalName.placeholder = "Sub-goal Name"
            // TODO: hide notes and reminder
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addGoalButton(_ sender: Any) {
        var goalData: [String: Any] = [
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
        
        if goalOrSubGoal == "sub_goal" {
            goalData["notes"] =  notesTF.text!
            goalData["reminder"] = "" // TODO: get reminder data somehow
            goalData["study_bashes"] = []
        }
        
        self.goalsColRef!.addDocument(data: goalData)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func hideShowCalendar(_ sender: Any) {
        calendar.isHidden = calendar.isHidden ? false : true
    }
    
    @IBAction func hideShowTimePicker(_ sender: Any) {
        time.isHidden = time.isHidden ? false : true
    }
    
    @IBAction func getTime(_ sender: Any) {
        print(time.date)
        // TODO: transfer the selected time to timeButton text
    }
}

extension AddGoalViewController: FSCalendarDataSource, FSCalendarDelegate {
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

extension AddGoalViewController: UISearchBarDelegate {
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

extension AddGoalViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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


