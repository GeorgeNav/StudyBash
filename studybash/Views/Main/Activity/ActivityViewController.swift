
import UIKit
import Charts
import Macaw
import GTProgressBar
import FirebaseFirestore
import FirebaseAuth

class ActivityViewController: UIViewController {
    let db: Firestore = Firestore.firestore()
    @IBOutlet weak var curvedlineChart: LineChart!
    @IBOutlet private var barChartView: MacawChartView!
    
    @IBOutlet weak var firstProgressBar: GTProgressBar!
    @IBOutlet weak var SecondProgressBar: GTProgressBar!
    @IBOutlet weak var ThirdProgressBar: GTProgressBar!
    @IBOutlet weak var FourthProgressBar: GTProgressBar!
    @IBOutlet weak var numGoals: UILabel!
    @IBOutlet weak var numSubGoals: UILabel!
    @IBOutlet weak var numHoursSpent: UILabel!
    @IBOutlet weak var subGoalsDueToday: UILabel!
    
    var dataEntries: [ChartDataEntry] = []
    
    var subGoalsData = [[String: Any]]()
    var allStudyBashes = [[String: Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getStats()
        // ProgressBar
        firstProgressBar.progress = 0.3
        SecondProgressBar.progress = 0.2
        ThirdProgressBar.progress = 0.6
        FourthProgressBar.progress = 0.9

        
        // LineChart
        let dataEntries = generateRandomEntries()
        curvedlineChart.dataEntries = dataEntries
        curvedlineChart.isCurved = true
        
        // BarChart
        barChartView.contentMode = .scaleAspectFit
        MacawChartView.playAnimation()
    }
    
    // LineChart
    func generateRandomEntries() -> [PointEntry] {
        var result: [PointEntry] = []
        for i in 0..<10 {
            let value = Int(arc4random() % 200)
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60*i))
            result.append(PointEntry(value: value, label: formatter.string(from: date)))
        }
        return result
    }
    
    func getStats() {
        let uid = Auth.auth().currentUser!.uid
        db.collection("users").document(uid)
            .collection("goals").addSnapshotListener({ (snapshot, error) in
            self.numGoals.text = "\(snapshot!.count)"
        })
        
        db.collectionGroup("sub_goals").whereField("uid_ref", isEqualTo: userDocRef!).addSnapshotListener({ (snapshot, error) in
            guard snapshot != nil else { return }
            self.numSubGoals.text = "\(snapshot!.count)"
            self.subGoalsData = [[String: Any]]()
            snapshot!.documents.forEach { (doc) in
                self.subGoalsData.append(doc.data())
            }
            
            var totalSeconds = 0
            self.subGoalsData.forEach { (subGoalData) in
                let statsData = subGoalData["statistics"]! as! [String: Any]
                totalSeconds += statsData["time_spent"]! as! Int
                
                let studyBashes = subGoalData["study_bashes"]! as! [[String: Any]]
                studyBashes.forEach { (studyBash) in
                    self.allStudyBashes.append(studyBash)
                }
                self.subGoalsData.append(subGoalData)
            }
            // Order subGoals based off time
            self.numHoursSpent.text = "\(Float(totalSeconds / 60 / 60))"
        })
    }

}


