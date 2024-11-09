import UIKit

class CircularTextView: UIView {
    
    enum RotationDirection {
        case clockwise
        case counterclockwise
        case autoReverse
    }
    
    struct Layer {
        var texts: [String]
        var radius: CGFloat
        var rotationAngle: CGFloat = 0
        var rotationSpeed: CGFloat // Speed of rotation
        var font: UIFont // Font for this layer
        var textColor: UIColor // Color for this layer
        var alpha: CGFloat // Alpha for this layer
        var direction: RotationDirection // Direction of rotation
        var reverseDuration: TimeInterval // Duration to stay in one direction before reversing

        // Initializer with default reverse duration
        init(texts: [String], radius: CGFloat, rotationSpeed: CGFloat, font: UIFont, textColor: UIColor, alpha: CGFloat, direction: RotationDirection, reverseDuration: TimeInterval = 0) {
            self.texts = texts
            self.radius = radius
            self.rotationSpeed = rotationSpeed
            self.font = font
            self.textColor = textColor
            self.alpha = alpha
            self.direction = direction
            self.reverseDuration = reverseDuration
        }
    }
    
    var layers: [Layer] = [] {
        didSet {
            self.setNeedsDisplay() // Redraw when layers are set
        }
    }
    
    private var displayLink: CADisplayLink?
    private var reverseTimers: [Timer] = []

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)

        for layer in layers {
            let textLength = layer.texts.count
            let angleIncrement = (2 * CGFloat.pi) / CGFloat(textLength)

            for (index, text) in layer.texts.enumerated() {
                let angle = angleIncrement * CGFloat(index) + layer.rotationAngle
                let x = center.x + layer.radius * cos(angle)
                let y = center.y + layer.radius * sin(angle)

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: layer.font,
                    .foregroundColor: layer.textColor.withAlphaComponent(layer.alpha)
                ]

                let textSize = text.size(withAttributes: attributes)

                let textRect = CGRect(x: x - textSize.width / 2, y: y - textSize.height / 2, width: textSize.width, height: textSize.height)
                text.draw(in: textRect, withAttributes: attributes)
            }
        }
        
        context?.restoreGState()
    }
    
    func startRotating() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateRotation))
        displayLink?.add(to: .main, forMode: .common)
        
        for index in layers.indices {
            if layers[index].direction == .autoReverse {
                startAutoReverse(for: index)
            }
        }
        
        // Start the pulse animation
        startPulseAnimation()
    }
    
    func stopRotating() {
        displayLink?.invalidate()
        displayLink = nil
        for timer in reverseTimers {
            timer.invalidate()
        }
        reverseTimers.removeAll()
        
        // Stop the pulse animation
        layer.removeAllAnimations()
    }
    
    @objc private func updateRotation() {
        for index in layers.indices {
            let layer = layers[index]
            var speed = layer.rotationSpeed
            
            switch layer.direction {
            case .clockwise:
                layers[index].rotationAngle += speed
            case .counterclockwise:
                layers[index].rotationAngle -= speed
            case .autoReverse:
                layers[index].rotationAngle += speed // Default to clockwise for first half
            }
        }
        self.setNeedsDisplay() // Redraw the text with the updated angles
    }
    
    private func startAutoReverse(for index: Int) {
        let layer = layers[index]
        var direction: RotationDirection = .clockwise
        
        // Change direction based on the specified duration
        let reverseTimer = Timer.scheduledTimer(withTimeInterval: layer.reverseDuration, repeats: true) { [weak self] _ in
            direction = (direction == .clockwise) ? .counterclockwise : .clockwise
            self?.layers[index].direction = direction
        }
        reverseTimers.append(reverseTimer)
    }
    
    private func startPulseAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 0.6
        pulseAnimation.toValue = 1.0 // Scale up
        pulseAnimation.duration = 1.5 // Duration of one pulse
        pulseAnimation.autoreverses = true // Reverse back to original size
        pulseAnimation.repeatCount = .infinity // Repeat indefinitely
        
        layer.add(pulseAnimation, forKey: "pulseAnimation")
    }
}
