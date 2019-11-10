//
//  ActivityViewController.swift
//  studybash
//
//  Created by George Navarro on 11/6/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import Charts


class ActivityViewController: UIViewController {
    
    
    @IBOutlet weak var lineChart: LineChartView!
    
    var dataEntries: [ChartDataEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setChart(values: [24.0,43.0,56.0,23.0,56.0,68.0,48.0,120.0,41.0])
        
    }
    
    func setChart(values: [Double]) {
        lineChart.noDataText = "No data available!"
        for i in 0..<values.count {
            print("chart point : \(values[i])")
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        let line1 = LineChartDataSet(entries: dataEntries, label: "Units Consumed")
        line1.colors = [NSUIColor.blue]
        line1.mode = .cubicBezier
        line1.cubicIntensity = 0.2
        
        let gradient = getGradientFilling()
        line1.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        line1.drawFilledEnabled = true
        
        let data = LineChartData()
        data.addDataSet(line1)
        lineChart.data = data
        lineChart.setScaleEnabled(false)
        lineChart.animate(xAxisDuration: 0.5)
        lineChart.drawGridBackgroundEnabled = false
        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawAxisLineEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawAxisLineEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false
        lineChart.legend.enabled = false
        lineChart.xAxis.enabled = false
        lineChart.leftAxis.enabled = false
        lineChart.rightAxis.enabled = false
        lineChart.xAxis.drawLabelsEnabled = false
        
    }
    
    private func getGradientFilling() -> CGGradient {
        // Setting fill gradient color
        let coloTop = UIColor(red: 141/255, green: 133/255, blue: 220/255, alpha: 1).cgColor
        let colorBottom = UIColor(red: 230/255, green: 155/255, blue: 210/255, alpha: 1).cgColor
        // Colors of the gradient
        let gradientColors = [coloTop, colorBottom] as CFArray
        // Positioning of the gradient
        let colorLocations: [CGFloat] = [0.7, 0.0]
        // Gradient Object
        return CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)!
    }
    
    
}
