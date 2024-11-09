import UIKit

final class DemoView: UIView {

    var path: UIBezierPath!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.darkGray
        complexShape()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        complexShape()
    }

    func complexShape() {
        path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        
        // Move to the right along the top
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0.0))
        
        // Move down the right side, creating a sharp corner
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height - 50.0))
        
        // Add a curve from the bottom right to the bottom left
        path.addCurve(to: CGPoint(x: 50.0, y: self.frame.size.height),
                      controlPoint1: CGPoint(x: self.frame.size.width - 100.0, y: self.frame.size.height - 50.0),
                      controlPoint2: CGPoint(x: 100.0, y: self.frame.size.height))
        
        // Move to the left bottom corner, creating a curve
        path.addQuadCurve(to: CGPoint(x: 0.0, y: self.frame.size.height - 50.0),
                          controlPoint: CGPoint(x: 0.0, y: self.frame.size.height))
        
        // Move back to the top left corner
        path.addLine(to: CGPoint(x: 0.0, y: 0.0))
        
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath

        self.layer.mask = shapeLayer
    }
}

