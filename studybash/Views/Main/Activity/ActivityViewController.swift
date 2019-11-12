
import UIKit
import Charts
import Macaw


class ActivityViewController: UIViewController {
    
    @IBOutlet weak var curvedlineChart: LineChart!
    @IBOutlet private var barChartView: MacawChartView!
    @IBOutlet weak var pieChart: PieChartView!
    
    var dataEntries: [ChartDataEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // LineChart
        let dataEntries = generateRandomEntries()
        curvedlineChart.dataEntries = dataEntries
        curvedlineChart.isCurved = true
        
        // BarChart
        barChartView.contentMode = .scaleAspectFit
        MacawChartView.playAnimation()
        
        // PieChart
        pieChart.sizeToFit()
        setupPieChart()
        
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
    
    // PieChart
    func setupPieChart() {
        pieChart.chartDescription?.enabled = false
        pieChart.drawHoleEnabled = false
        pieChart.isUserInteractionEnabled = true
        pieChart.legend.enabled = true
        
        var entries: [PieChartDataEntry] = Array()
        
        entries.append(PieChartDataEntry(value: 20, label: "Quiz"))
        entries.append(PieChartDataEntry(value: 20, label: "Assignment"))
        entries.append(PieChartDataEntry(value: 20, label: "assignments"))
        entries.append(PieChartDataEntry(value: 20, label: "assignments"))
        entries.append(PieChartDataEntry(value: 20, label: "assignments"))
        
//        entries.append(PieChartDataEntry(value: 23.4))
//        entries.append(PieChartDataEntry(value: 34))
//        entries.append(PieChartDataEntry(value: 12.4))
//        entries.append(PieChartDataEntry(value: 53))
//        entries.append(PieChartDataEntry(value: 12))
        
        let dataSet = PieChartDataSet(entries: entries, label: " ") // Lables
        
        let c1 = UIColor(red:0.37, green:0.37, blue:0.37, alpha:1.0)
        let c2 = UIColor(red:0.31, green:0.00, blue:0.28, alpha:1.0)
        let c3 = UIColor(red:0.21, green:0.00, blue:0.17, alpha:1.0)
        let c4 = UIColor(red:0.16, green:0.00, blue:0.15, alpha:1.0)
        let c5 = UIColor(red:0.07, green:0.00, blue:0.11, alpha:1.0)
        
        dataSet.colors = [c1, c2, c3, c4, c5]
        dataSet.drawValuesEnabled = true
        pieChart.data = PieChartData(dataSet: dataSet)
    }
    
    
}
