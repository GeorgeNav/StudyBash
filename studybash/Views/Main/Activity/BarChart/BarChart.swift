//
//  BarChart.swift
//  studybash
//
//  Created by Mustafa AL-Jaburi on 11/11/19.
//  Copyright © 2019 Navality. All rights reserved.


import Foundation
import UIKit
import Macaw


struct DummyData {
    var showNumber: String
    var viewCount: Double
}

class MacawChartView: MacawView {
    
    static let lastFive                 = createDummyData()
    static let maxValue                 = 6000
    static let maxValueLineHeight       = 180
    static let lineWidth: Double        = 275 // Horiz. Line
    static let dataDivisor              = Double(maxValue/maxValueLineHeight)
    static let adjustedData: [Double]   = lastFive.map({ $0.viewCount / dataDivisor})
    static var animation : [Animation]  = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(node: MacawChartView.createChart(), coder: aDecoder)
        backgroundColor = .clear
    }
    
    private static func createChart() -> Group {
        var items: [Node] = addYAxis() + addXAxis()
        items.append(createBars())
        return Group(contents: items, place: .identity)
    }
    
    private static func addYAxis() -> [Node] {
        let maxLines                = 6
        let lineInterval            = Int(maxValue/maxLines)
        let yAxisHeight: Double     = 200
        let lineSpacing: Double     = 30
        
        var newNode: [Node]         = []
        for i in 1 ... maxLines {
            let y = yAxisHeight - (Double(i) * lineSpacing)
            let valueLine = Line(x1: -5, y1: y, x2: lineWidth, y2: y).stroke(fill: Color.white.with(a: 0.10))
            let valueText = Text(text: "\(i * lineInterval)" , align: .max, baseline: .mid, place: .move(dx: -10, dy: y))
            valueText.fill = Color.white
            
            newNode.append(valueLine)
            newNode.append(valueText)
        }
        
        let yAxix = Line(x1: 0, y1: 0, x2: 0, y2: yAxisHeight).stroke(fill: Color.white.with(a: 0.25))
        newNode.append(yAxix)
        
        return newNode
    }
    
    private static func addXAxis() -> [Node] {
        let chartBaseY : Double     = 200
        var newNode: [Node]         = []
        
        for i in 1...adjustedData.count {
            let x = (Double(i) * 50) // Space between bars
            let valueText = Text(text: lastFive[i - 1].showNumber, align: .max, baseline: .mid, place: .move(dx: x, dy: chartBaseY + 15))
            valueText.fill = Color.white
            newNode.append(valueText)
        }
        
        let xAxis = Line(x1: 0, y1: chartBaseY, x2: lineWidth, y2: chartBaseY).stroke(fill: Color.white.with(a: 0.25))
        newNode.append(xAxis)
        
        return newNode
    }
    
    private static func createBars() -> Group {
        let fill = LinearGradient(degree: 90, from: .white, to: Color(val: 0xff4704).with(a: 0.10))
        let items = adjustedData.map { _ in Group() }
        
        animation = items.enumerated().map {(i: Int, items: Group) in
            items.contentsVar.animation(delay: Double(i) * 0.1) { t in
                let height = adjustedData[i] * t
                let rect = Rect(x: Double(i) * 50 + 25, y: 200 - height, w: 30, h: height)
                return [rect.fill(with: fill)]
            }
        }
        return items.group()
    }
    
    static func playAnimation() {
        animation.combine().play()
    }
    
    private static func createDummyData() -> [DummyData] {
        let one    = DummyData(showNumber: "55", viewCount: 3456)
        let two    = DummyData(showNumber: "56", viewCount: 2344)
        let three  = DummyData(showNumber: "57", viewCount: 4224)
        let four   = DummyData(showNumber: "58", viewCount: 5234)
        let five   = DummyData(showNumber: "59", viewCount: 5932)
        return[one,two,three,four,five]
    }
}
