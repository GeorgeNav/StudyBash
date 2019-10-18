//
//  AddGoalViewController.swift
//  studybash
//
//  Created by George Navarro on 10/15/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import FSCalendar

let typeCellIdentifier = "type_cell"

class AddGoalViewController: UIViewController, UISearchBarDelegate {
    fileprivate weak var calendar: FSCalendar!
    var selectedDate: Date = Date()
    @IBOutlet weak var time: UIDatePicker!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var goalName: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notesTF: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var typesCV: UICollectionView!
    var typeNames = ["New York, NY", "Los Angeles, CA", "Chicago, IL", "Houston, TX",
    "Philadelphia, PA", "Phoenix, AZ", "San Diego, CA", "San Antonio, TX",
    "Dallas, TX", "Detroit, MI", "San Jose, CA", "Indianapolis, IN",
    "Jacksonville, FL", "San Francisco, CA", "Columbus, OH", "Austin, TX",
    "Memphis, TN", "Baltimore, MD", "Charlotte, ND", "Fort Worth, TX"]
    var filteredData: [String] = [String]()

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
    @IBAction func cancelButton(_ sender: Any) {
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
    }
    
    @IBAction func createGoalButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "add_goal_to_goal", sender: self)
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

