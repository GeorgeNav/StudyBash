


import UIKit
import FSCalendar
import FirebaseAuth
import FirebaseFirestore
import NotificationCenter
import UserNotifications

let typeCellIdentifier = "type_cell"

class AddEditGoalViewController: UIViewController {
    let db: Firestore = Firestore.firestore()
    
    // UI Elements
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var time: UIDatePicker!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var goalName: UITextField!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var notesTF: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var typesCV: UICollectionView!
    @IBOutlet weak var deleteGoalButton: UIButton!
    
    var isKeyboardAppear = false

    
    // Logic Elements
    var userDocRef: DocumentReference?
    var goalTypes = [[String: Any]]()
    var typeNames = [String]()
    var filteredTypes = [[String: Any]]()
    var goalsColRef: CollectionReference?
    var goalDocRef: DocumentReference?
    var useCase: String = ""
    var goalData: [String: Any] = [String: Any]()
    let dateTimeFormat = DateFormatter()
    let timeFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredTypes = goalTypes
        typesCV.delegate = self
        typesCV.dataSource = self
        searchBar.delegate = self
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "add_edit_cal_cell")
        calendar.isHidden = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        dateTimeFormat.dateFormat = "MMMM dd, yyyy  hh:mm:ss"
        timeFormatter.dateFormat = "h:mm a"
        if ["add_goal", "add_sub_goal"].contains(useCase) {
            deleteGoalButton.isEnabled = false
            deleteGoalButton.isHidden = true
            let currentDate = Date()
            // Prep calendar and date button
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMMM dd, yyyy"
            self.dateButton.setTitle(dateFormat.string(from: currentDate), for: .normal)
            self.calendar.select(currentDate)
            time.setDate(currentDate, animated: true)
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            timeButton.setTitle(timeFormatter.string(from: currentDate), for: .normal)
            time.date = currentDate
            
            // Prep textual labels and fields
            if useCase == "add_goal" {
                titleL.text = "Add Goal"
                goalName.placeholder = "Goal Name"
                // TODO: hide notes and reminder
            } else if useCase == "add_sub_goal" {
                titleL.text = "Add Sub-goal"
                goalName.placeholder = "Sub-goal Name"
            }
            
            // Data Prep
            goalData = [
                "date_created": Timestamp(date: currentDate),
                "due_date": Timestamp(date: currentDate),
                "finished": false,
                "notes": "",
                "reminder": [
                    "type": "none",
                    "value": 0
                ],
                "statistics": [
                    "time_spent": 0
                ],
                "types": [],
                "uid_ref": userDocRef!
            ]
            
            if useCase == "add_sub_goal" {
                goalData["study_bashes"] = []
            }
        } else if ["edit_goal", "edit_sub_goal"].contains(useCase) {
            deleteGoalButton.isEnabled = true
            deleteGoalButton.isHidden = false
            goalDocRef = (goalData["ref"]! as! DocumentReference)
            
            let dueDate = (goalData["due_date"]! as! Timestamp).dateValue()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            dateButton.setTitle(dateFormatter.string(from: dueDate), for: .normal)
            self.calendar.select(dueDate)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            timeButton.setTitle(timeFormatter.string(from: dueDate), for: .normal)
            time.date = dueDate
            
            goalName.text = goalData["name"]! as? String
            notesTF.text = goalData["notes"]! as? String
            
            if useCase == "edit_goal" {
                // TODO: make UI different
                titleL.text = "Your Goal"
            } else if useCase == "edit_sub_goal" {
                // TODO: make UI different
                titleL.text = "Your Sub-goal"
            }
        }
    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if !isKeyboardAppear {
//            if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
//                if self.view.frame.origin.y == 0 {
//                    self.view.frame.origin.y -= 65
//                }
//            }
//            isKeyboardAppear = true
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if isKeyboardAppear {
//            if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
//                if self.view.frame.origin.y != 0{
//                    self.view.frame.origin.y = 0
//                }
//            }
//            isKeyboardAppear = false
//        }
//    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addEditGoalButton(_ sender: Any) {
        if useCase == "add_goal" || useCase == "add_sub_goal" {
            addGoal()
        } else if useCase == "edit_goal" || useCase == "edit_sub_goal" {
            editGoal()
        }
    }
    
    func addGoal() {
        guard goalName.text?.count != 0 else {
            // TODO: tell user to enter a name
            return
        }
        self.goalsColRef!.addDocument(data: goalData)
        self.dismiss(animated: true, completion: nil)
    }
    
    func editGoal() {
        let goalDocRef = goalData.removeValue(forKey: "ref")! as! DocumentReference
        
        goalDocRef.updateData(goalData)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteGoal(_ sender: Any) {
        if useCase == "edit_goal" {
            goalDocRef?.collection("sub_goals").getDocuments(completion: {(snapshot, error) in
                guard snapshot != nil else { print("Error:", error!); return }
                snapshot!.documents.forEach({(doc) in
                    doc.reference.delete()
                })
                self.goalDocRef?.delete()
                self.dismiss(animated: true, completion: nil)
            })
        } else if useCase == "edit_sub_goal" {
            goalDocRef?.delete()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func toggleCalendar(_ sender: Any) {
        calendar.isHidden = !calendar.isHidden
    }
    
    @IBAction func toggleTime(_ sender: Any) {
        time.isHidden = !time.isHidden
    }
    
    @IBAction func getTime(_ sender: Any) {
        let cal = Calendar.current
        let timeComp = cal.dateComponents([.hour, .minute, .timeZone], from: time.date)
        let date = (goalData["due_date"]! as! Timestamp).dateValue()
        let newDate = date.setTime(hour: timeComp.hour!, min: timeComp.minute!, sec: 0, timeZoneAbbrev: timeComp.timeZone!.abbreviation()!)!
        
        print(dateTimeFormat.string(from: newDate))
        
        goalData["due_date"] = Timestamp(date: newDate)
        
        timeButton.setTitle(timeFormatter.string(from: newDate), for: .normal)
    }
    
    @IBAction func getGoalName(_ sender: Any) {
        goalData["name"] = goalName.text!
    }
    
    @IBAction func getNotes(_ sender: Any) {
        goalData["notes"] = notesTF.text!
    }
}

extension AddEditGoalViewController: FSCalendarDataSource, FSCalendarDelegate {
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        goalData["due_date"] = Timestamp(date: date)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMMM dd, yyyy"
        self.dateButton.setTitle(dateFormat.string(from: date), for: .normal)
        calendar.isHidden = true
    }
    
    public func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "add_edit_cal_cell", for: date, at: position)
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
        filteredTypes = searchText.isEmpty ? goalTypes : goalTypes.filter({ (type) -> Bool in
            let nameValue = type["name"]! as! String
            return nameValue.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        typesCV.reloadData()
    }
}

extension AddEditGoalViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = typesCV.dequeueReusableCell(withReuseIdentifier: typeCellIdentifier, for: indexPath) as! AddGoalCollectionViewCell
        let goalTypesRefs = goalData["types"]! as! [DocumentReference]
        let selectedType = filteredTypes[indexPath.row]["ref"]! as! DocumentReference
        
        let imageName = !goalTypesRefs.contains(selectedType) ? "catBackground" : "catBackgroundSelected"
        cell.toggleStateIV.image = UIImage(named: imageName)
        cell.typeNameL.text = filteredTypes[indexPath.row]["name"]! as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var typeRefs = goalData["types"]! as! [DocumentReference]
        let selectedTypeRef = filteredTypes[indexPath.row]["ref"]! as! DocumentReference
        if typeRefs.contains(selectedTypeRef) {
            typeRefs = typeRefs.filter({ (typeRef) -> Bool in
                return typeRef != selectedTypeRef
            })
        } else {
            typeRefs.append(selectedTypeRef)
        }
        goalData["types"] = typeRefs
        typesCV.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        return CGSize(width: screenSize.width/4, height: 50)
    }
}

extension Date {
    public func setTime(hour: Int, min: Int, sec: Int, timeZoneAbbrev: String) -> Date? {
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


