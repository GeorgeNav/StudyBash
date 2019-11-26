
import UIKit
import Charts
import Macaw
import GTProgressBar


class ActivityViewController: UIViewController {
    
    @IBOutlet weak var curvedlineChart: LineChart!
    @IBOutlet private var barChartView: MacawChartView!
    
    @IBOutlet weak var firstProgressBar: GTProgressBar!
    @IBOutlet weak var SecondProgressBar: GTProgressBar!
    @IBOutlet weak var ThirdProgressBar: GTProgressBar!
    @IBOutlet weak var FourthProgressBar: GTProgressBar!
    
    
    var dataEntries: [ChartDataEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    

}


