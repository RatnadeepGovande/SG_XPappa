import UIKit

@IBDesignable
class CircleViewObject: UIButton {
    
    @IBInspectable var fillColor: UIColor = UIColor.green
    @IBInspectable var innerClockColor: UIColor = UIColor.red
    @IBInspectable var strokeColor: UIColor = UIColor.green
    @IBInspectable var plusDynamicWidth: CGFloat = 0.2
    
    var totalValues = Int()
    let circleShape = CAShapeLayer()
    var backgroundCircle : UIBezierPath?

    override func draw(_ rect: CGRect) {
        
        //create the circle
        backgroundCircle = UIBezierPath(ovalIn: rect)
        backgroundCircle?.lineWidth = 3.0
        fillColor.setFill()
        backgroundCircle?.fill()
    }
    
    
   public func circlePathWithCenter(percentageOfCircle:CGFloat)  {
    
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * plusDynamicWidth
    
        let startAngle = -CGFloat.pi / 2  // This corresponds to 12 0'clock
        // vary this to vary the size of the segment, in per cent
        let centre = CGPoint (x: self.frame.size.width / 2, y: self.frame.size.height / 2 )
        let radius = self.frame.size.width / 2 + plusWidth/2
        let arc = CGFloat.pi * 2 * percentageOfCircle / CGFloat(totalValues)  // i.e. the proportion of a full circle
        
        // Start a mutable path
        let cPath = UIBezierPath()
        // Move to the centre
        cPath.move(to: centre)
        // Draw a line to the circumference
        cPath.addLine(to: CGPoint(x: centre.x + radius * cos(startAngle), y: centre.y + plusWidth/2 + radius * sin(startAngle)))
        // NOW draw the arc
        cPath.addArc(withCenter: centre, radius: radius, startAngle: startAngle, endAngle: arc + startAngle, clockwise: true)
        // Line back to the centre, where we started (or the stroke doesn't work, though the fill does)
        cPath.addLine(to: CGPoint(x: centre.x, y: centre.y))
        // n.b. as @MartinR points out `cPath.close()` does the same!
        
        // circle shape
        circleShape.path = cPath.cgPath
        //circleShape.strokeColor = UIColor.black.cgColor
        circleShape.fillColor = innerClockColor.cgColor
        circleShape.lineWidth = 1.0
        
        self.layer.addSublayer(circleShape)
    
    
    }
}
