

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayL: UILabel!
    @IBOutlet weak var circleV: UIView!
    var date = Date()
    
    func DrawCircle(progress: Double) {
        guard progress >= 0 && progress <= 1 else { return }
        
        let circleCenter = circleV.center
        
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: (circleV.bounds.width/2 - 5), startAngle: -CGFloat.pi/2, endAngle: (2 * CGFloat.pi), clockwise: true)
        
        let CircleLayer = CAShapeLayer()
        CircleLayer.path = circlePath.cgPath
        CircleLayer.strokeColor = UIColor.red.cgColor
        CircleLayer.lineWidth = 2
        CircleLayer.strokeEnd = 0
        CircleLayer.fillColor = UIColor.clear.cgColor
        CircleLayer.lineCap = CAShapeLayerLineCap.round
        
        let Animation = CABasicAnimation(keyPath: "strokeEnd")
        Animation.duration = 1
        Animation.toValue = progress
        Animation.fillMode = CAMediaTimingFillMode.forwards
        Animation.isRemovedOnCompletion = false
        
        CircleLayer.add(Animation, forKey: nil)
        circleV.layer.addSublayer(CircleLayer)
        circleV.layer.backgroundColor = UIColor.clear.cgColor
    }
    
}
