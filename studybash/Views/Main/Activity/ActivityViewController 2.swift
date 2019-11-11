
import UIKit
import Charts
import Macaw

class ActivityViewController: UIViewController {
    
    @IBOutlet weak var curvedlineChart: LineChart!
    @IBOutlet weak var barChart: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // LineChart
        let dataEntries = generateRandomEntries()
        curvedlineChart.dataEntries = dataEntries
        curvedlineChart.isCurved = true
        
        // BarChart
        
        
    }
    
    // LineChart
    private func generateRandomEntries() -> [PointEntry] {
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
