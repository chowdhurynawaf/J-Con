//
//  Extensions.swift
//  j-lingo
//
//  Created by as on 5/30/24.
//

import UIKit
import ImageIO

extension UIImageView {
    func setLocalImage(named imageName: String) {
        // Check if the image is already cached
        if let cachedImage = ImageCache.shared.object(forKey: imageName as NSString) {
            self.image = cachedImage
            return
        }
        
        // Load the image from the app's bundle
        if let image = UIImage(named: imageName) {
            // Cache the image
            ImageCache.shared.setObject(image, forKey: imageName as NSString)
            
            // Set the image to the UIImageView
            self.image = image
        }
    }
}

extension UIImageView {
    func setImage(with url: URL) {
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            return
        }
        
        // Fetch image from URL
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            // Cache the image
            ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}


extension UIImageView {
    func setImageAsync(named imageName: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let image = UIImage(named: imageName)
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
}

extension UIViewController {
    func pushViewController<T: UIViewController>(ofType type: T.Type, animated: Bool = true) {
        let nibName = String(describing: T.self)
        let viewController = T(nibName: nibName, bundle: nil)
        self.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func pushWithData<T: UIViewController>(ofType type: T.Type, animated: Bool = true, configure: ((T) -> Void)? = nil) {
           let nibName = String(describing: T.self)
           let viewController = T(nibName: nibName, bundle: nil)
           configure?(viewController)
           self.navigationController?.pushViewController(viewController, animated: animated)
       }
}

//MARK: - UIView

extension UIView {
    func createRotatingCharactersAnimation(characters: [String], layerCount: Int = 5) {
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        
        for (index, character) in characters.prefix(layerCount).enumerated() {
            let label = UILabel()
            label.text = character
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20)
            label.sizeToFit()
            
            let radius = CGFloat(30 + index * 20)
            label.center = CGPoint(x: centerX, y: centerY - radius)
            
            addSubview(label)
            
            let orbitAnimation = CAKeyframeAnimation(keyPath: "position")
            orbitAnimation.path = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY),
                                               radius: radius,
                                               startAngle: 0,
                                               endAngle: CGFloat.pi * 2,
                                               clockwise: true).cgPath
            orbitAnimation.duration = Double(index + 1) * 2
            orbitAnimation.repeatCount = .infinity
            orbitAnimation.calculationMode = .paced
            orbitAnimation.rotationMode = .rotateAuto
            
            let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.duration = 1
            pulseAnimation.fromValue = 0.8
            pulseAnimation.toValue = 1.2
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = .infinity
            
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [orbitAnimation, pulseAnimation]
            animationGroup.duration = max(orbitAnimation.duration, pulseAnimation.duration * 2)
            animationGroup.repeatCount = .infinity
            
            label.layer.add(animationGroup, forKey: "rotatingCharacterAnimation")
        }
    }
    
    func stopRotatingCharactersAnimation() {
        subviews.forEach { $0.layer.removeAllAnimations() }
    }
}

extension UIView {
    
    // Function to add rotating and scaling animation
    func addRotatingLayers(characters: [String], numberOfLayers: Int = 5) {
        guard characters.count > 0 else { return }
        
        for i in 0..<numberOfLayers {
            let label = UILabel()
            label.text = characters[i % characters.count] // Cycle through characters
            label.font = UIFont.systemFont(ofSize: 40)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            
            // Center the label in the view
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
            // Set up animation
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotationAnimation.fromValue = 0
            rotationAnimation.toValue = Double.pi * 2
            rotationAnimation.duration = 4.0
            rotationAnimation.repeatCount = .infinity
            rotationAnimation.autoreverses = true
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = 1.2
            scaleAnimation.duration = 1.0
            scaleAnimation.repeatCount = .infinity
            scaleAnimation.autoreverses = true
            
            // Group animations
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [rotationAnimation, scaleAnimation]
            groupAnimation.duration = 4.0
            groupAnimation.repeatCount = .infinity
            groupAnimation.autoreverses = true
            
            label.layer.add(groupAnimation, forKey: "rotateAndScale")
        }
    }
    
    // Function to stop the animation
    func stopRotatingLayers() {
        self.layer.sublayers?.forEach { $0.removeAllAnimations() }
        self.subviews.forEach { $0.removeFromSuperview() }
    }
}




extension UIView {

    /// Fills the view with a specified color up to a given percentage.
    /// - Parameters:
    ///   - color: The color to fill the view with.
    ///   - percentage: The percentage of the view to fill (0.0 to 1.0).
    ///   - isHorizontal: A boolean to specify if the fill should be horizontal. Default is vertical.
    func fillWithColor(_ color: UIColor, percentage: CGFloat, isHorizontal: Bool = false) {
        // Ensure the percentage is between 0 and 1
        let validPercentage = max(0, min(percentage, 1))
        
        // Remove any existing sublayers before adding a new one
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        // Create a colored layer
        let fillLayer = CALayer()
        fillLayer.backgroundColor = color.cgColor
        fillLayer.cornerRadius = self.layer.cornerRadius
        fillLayer.masksToBounds = true
        
        // Calculate the frame based on the percentage and direction
        if isHorizontal {
            fillLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width * validPercentage, height: self.bounds.height)
        } else {
            fillLayer.frame = CGRect(x: 0, y: self.bounds.height * (1 - validPercentage), width: self.bounds.width, height: self.bounds.height * validPercentage)
        }
        
        // Add the layer to the view
        self.layer.addSublayer(fillLayer)
    }
}

extension UIView {
 
    func makeSpherical() {
        let smallestDimension = min(self.bounds.width, self.bounds.height)
        self.layer.cornerRadius = smallestDimension / 2
        self.layer.masksToBounds = true
    }
    

    func applyDropShadow(color: UIColor = .black,
                         opacity: Float = 0.5,
                         offset: CGSize = CGSize(width: 0, height: 1),
                         radius: CGFloat = 1.5,
                         shouldRasterize: Bool = true,
                         rasterizationScale: CGFloat? = nil) {
        // Apply shadow properties
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        
        // Optional rasterization for performance improvement
        layer.shouldRasterize = shouldRasterize
        if shouldRasterize {
            layer.rasterizationScale = rasterizationScale ?? UIScreen.main.scale
        }
        
        // For better performance when rendering shadows
        layer.masksToBounds = false
    }
}


extension UIView: CAAnimationDelegate {
    
    func animateFillWithColor(_ color: UIColor, duration: CFTimeInterval, completion: (() -> Void)? = nil) {
        // Create a CAShapeLayer
        let fillLayer = CAShapeLayer()
        fillLayer.frame = self.bounds
        
        // Create a path that covers the entire view
        let path = UIBezierPath(rect: self.bounds)
        fillLayer.path = path.cgPath
        
        // Set the initial fill color to clear
        fillLayer.fillColor = UIColor.clear.cgColor
        
        // Add the fillLayer to the view's layer
        self.layer.addSublayer(fillLayer)
        
        // Create a CABasicAnimation to animate the fill color
        let fillAnimation = CABasicAnimation(keyPath: "fillColor")
        fillAnimation.fromValue = UIColor.clear.cgColor
        fillAnimation.toValue = color.cgColor
        fillAnimation.duration = duration
        fillAnimation.delegate = self
        
        // Add a key for the animation to identify it in the delegate method
        fillAnimation.setValue(completion, forKey: "completion")
        fillAnimation.setValue(fillLayer, forKey: "fillLayer")
        
        // Add the animation to the fillLayer
        fillLayer.add(fillAnimation, forKey: "fillColor")
        
        // Set the final fill color (needed to retain color after animation ends)
        fillLayer.fillColor = color.cgColor
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            // Retrieve the completion handler and call it if available
            if let completion = anim.value(forKey: "completion") as? (() -> Void) {
                completion()
            }
            
            // Retrieve the fillLayer and remove it from the super layer
            if let fillLayer = anim.value(forKey: "fillLayer") as? CAShapeLayer {
                fillLayer.removeFromSuperlayer()
            }
            
            
        }
    }
}

extension UIView {
    func loadFromNib(named nibName: String) {
        let nib = UINib(nibName: nibName, bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
}

extension UIView {
    
    func applyGradient(colors: [CGColor], locations: [NSNumber]? = nil, startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = self.bounds
        
        // Remove any previous gradient layers to avoid layering multiple gradients
        self.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func applyVerticalGradient(colors: [CGColor]) {
        applyGradient(colors: colors, startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1))
    }
    
    func applyHorizontalGradient(colors: [CGColor]) {
        applyGradient(colors: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
    }
}


extension UIView  {
    public func addWaveBackground(to view: UIView){
        let leftDrop:CGFloat = 0.4
        let rightDrop: CGFloat = 0.3
        let leftInflexionX: CGFloat = 0.4
        let leftInflexionY: CGFloat = 0.47
        let rightInflexionX: CGFloat = 0.6
        let rightInflexionY: CGFloat = 0.22

        let backView = UIView(frame: view.frame)
        backView.backgroundColor = .gray
        view.addSubview(backView)
        let backLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x:0, y: view.frame.height * leftDrop))
        path.addCurve(to: CGPoint(x:view.frame.width, y: view.frame.height * rightDrop),
                      controlPoint1: CGPoint(x: view.frame.width * leftInflexionX, y: view.frame.height * leftInflexionY),
                      controlPoint2: CGPoint(x: view.frame.width * rightInflexionX, y: view.frame.height * rightInflexionY))
        path.addLine(to: CGPoint(x:view.frame.width, y: 0))
        path.close()
        backLayer.fillColor = UIColor.blue.cgColor
        backLayer.path = path.cgPath
        backView.layer.addSublayer(backLayer)
     }
}


extension UIView {
    
    func addGradientBorderAnimation(colors: [UIColor], borderWidth: CGFloat = 1.0, duration: CFTimeInterval = 1.0) {
        // Remove any existing gradient border layer
        if let existingBorderLayer = self.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            existingBorderLayer.removeFromSuperlayer()
        }
        
        // Create the gradient layer
        let gradientBorderLayer = CAGradientLayer()
        gradientBorderLayer.frame = self.bounds
        gradientBorderLayer.colors = colors.map { $0.cgColor }
        gradientBorderLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientBorderLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientBorderLayer.locations = [0.0, 1.0]
        
        // Create a mask layer to restrict the gradient to the border area
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2), cornerRadius: self.layer.cornerRadius).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = borderWidth
        maskLayer.lineCap = .round
        
        // Add the mask layer to the gradient layer
        gradientBorderLayer.mask = maskLayer
        
        // Add the gradient border layer to the view
        self.layer.addSublayer(gradientBorderLayer)
        
        // Animate the gradient colors
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.fromValue = [UIColor.systemGreen, UIColor.black.cgColor] // Example start colors
        colorAnimation.toValue = colors.map { $0.cgColor }
        colorAnimation.duration = duration
        colorAnimation.repeatCount = .infinity
        
        gradientBorderLayer.add(colorAnimation, forKey: "gradientBorderAnimation")
    }
}

extension UIView{
public func addNeumorphicEffect(cornerRadius: CGFloat = 15.0, themeColor:
                                UIColor = .white) {
    // Remove any existing shadow layers
    self.layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }
    
    // Configure the view's basic properties
    self.layer.cornerRadius = cornerRadius
    self.layer.masksToBounds = false
    
    // Light shadow (for the "inset" effect)
    let lightShadow = CAShapeLayer()
    lightShadow.frame = bounds
    lightShadow.backgroundColor = themeColor.cgColor
    lightShadow.cornerRadius = cornerRadius
    lightShadow.shadowColor = UIColor.white.cgColor
    lightShadow.shadowOffset = CGSize(width: -4.0, height: -4.0)
    lightShadow.shadowOpacity = 0.8
    lightShadow.shadowRadius = 6
    self.layer.insertSublayer(lightShadow, at: 0)
    
    // Dark shadow (for the "lifted" effect)
    let darkShadow = CAShapeLayer()
    darkShadow.frame = bounds
    darkShadow.backgroundColor = themeColor.cgColor
    darkShadow.cornerRadius = cornerRadius
    darkShadow.shadowColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0).cgColor
    darkShadow.shadowOffset = CGSize(width: 4.0, height: 4.0)
    darkShadow.shadowOpacity = 0.8
    darkShadow.shadowRadius = 6
    self.layer.insertSublayer(darkShadow, at: 0)
}

}

extension UIView {
    
    func flip360(duration: TimeInterval = 1.0, repeatCount : Int) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.y")
        animation.fromValue = 0.0
        animation.toValue = CGFloat.pi * 2.0  // 360 degrees in radians
        animation.duration = duration
        animation.repeatCount = Float(repeatCount)
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(animation, forKey: nil)
        
    }
    
  func animateToZeroSize(duration: TimeInterval = 1.5, completion: (() -> Void)? = nil) {
        let animation = CABasicAnimation(keyPath: "bounds.size")
        animation.fromValue = NSValue(cgSize: self.frame.size)
        animation.toValue = NSValue(cgSize: CGSize.zero)
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        self.layer.add(animation, forKey: nil)
    }
    
    func fadeIn(duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
       if alpha == 1.0 { return } // Skip animation if already fully visible
       alpha = 0.0 // Set initial alpha (assuming it's not already 0)
       UIView.animate(withDuration: duration, animations: {
           self.alpha = 1.0 // Animate alpha to 1.0
           self.showView()
       })
   }

    func fadeOut(duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
       if alpha == 0.0 { return } // Skip animation if already hidden
       UIView.animate(withDuration: duration, animations: {
         self.alpha = 0.0 // Animate alpha to 0.0
         self.hideView()
       })
     }
    
     func hideView() {
        self.isHidden = true
    }
    
    fileprivate func showView() {
        self.isHidden = false
    }
    
    func animateConstraintWithSpring(_ constraint: NSLayoutConstraint, to newConstant: CGFloat, duration: TimeInterval, damping: CGFloat, initialSpringVelocity: CGFloat, completion: ((Bool) -> Void)? = nil) {
         // Update the constraint's constant value
         constraint.constant = newConstant
         
         // Animate the layout change with a spring animation
         UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
             self.layoutIfNeeded()
         }, completion: completion)
     }
 } 
    
   
//MARK: - UILabel

extension UILabel {
    
    func setAngle(_ angle: CGFloat) {
         let angleInRadians = angle * CGFloat.pi / 180.0
         let rotationTransform = CGAffineTransform(rotationAngle: angleInRadians)
         self.transform = rotationTransform
     }
    
    func animateCursiveWriting(initialText: String = "J-Lingo", duration: TimeInterval, completion: @escaping () -> Void) {
        self.text = ""
        let characterArray = Array(initialText)
        var currentIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: duration / Double(initialText.count), repeats: true) { timer in
            guard currentIndex < characterArray.count else {
                timer.invalidate()
                completion()
                return
            }
            self.text?.append(characterArray[currentIndex])
            currentIndex += 1
            
            
        }
        
    }
}


//MARK: - UILabel

extension UILabel {
    
    func flip(duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil) {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromTop, .showHideTransitionViews]

        UIView.transition(with: self, duration: duration, options: transitionOptions, animations: {
            self.isHidden = true
        }, completion: { _ in
            UIView.transition(with: self, duration: duration, options: transitionOptions, animations: {
                self.isHidden = false
            }, completion: completion)
        })
    }
}


extension UILabel {
    
    func swing(duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [0, 0.05, -0.05, 0.05, 0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.duration = duration
        animation.isAdditive = true
        layer.add(animation, forKey: "swing")
        completion?(true)
    }
}


extension UILabel {
    
    func shake(duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
        completion?(true)
    }
}


extension UILabel {
    
    func rotateAndScale(duration: TimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        self.transform = CGAffineTransform(rotationAngle: 0).scaledBy(x: 1, y: 1)
        UIView.animate(withDuration: duration, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.transform = CGAffineTransform(rotationAngle: .pi).scaledBy(x: 1.5, y: 1.5)
        }, completion: completion)
    }
}


extension UILabel {
    
    func zoomOut(duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: completion)
    }
}


extension UILabel {
    
    func zoomIn(duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: completion)
    }
}


extension UILabel {
    
    func flash(duration: TimeInterval = 0.5, repeatCount: Float = Float.infinity, completion: ((Bool) -> Void)? = nil) {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = duration
        flash.fromValue = 1.0
        flash.toValue = 0.1
        flash.autoreverses = true
        flash.repeatCount = repeatCount
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        layer.add(flash, forKey: nil)
    }
}


extension UILabel {
    
    func pulsate(duration: TimeInterval = 0.8, repeatCount: Float = Float.infinity, completion: ((Bool) -> Void)? = nil) {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = duration
        pulse.fromValue = 1.0
        pulse.toValue = 1.1
        pulse.autoreverses = true
        pulse.repeatCount = repeatCount
        pulse.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        layer.add(pulse, forKey: nil)
    }
}


extension UILabel {
    
    // Fade In Animation
    func fadeIn(duration: TimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        self.alpha = 0
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: completion)
    }
    
    // Fade Out Animation
    func fadeOut(duration: TimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        self.alpha = 1
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: completion)
    }
    
    // Slide In from Left
    func slideInFromLeft(duration: TimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        let initialFrame = self.frame
        self.frame = CGRect(x: -self.frame.width, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        UIView.animate(withDuration: duration, animations: {
            self.frame = initialFrame
        }, completion: completion)
    }
    
    // Slide Out to Right
    func slideOutToRight(duration: TimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.frame = CGRect(x: UIScreen.main.bounds.width, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }, completion: completion)
    }
    
    // Bounce Animation
    func bounce(duration: TimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.transform = .identity
        }, completion: completion)
    }
    
    // Rotate Animation
    func rotate(duration: TimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(rotationAngle: .pi)
        }, completion: { finished in
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }, completion: completion)
        })
    }
}

//MARK: - UIColor

extension UIColor {
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }

        guard hexString.count == 6 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

//MARK: - Tableview


extension UITableView {
    
    // Register a UITableViewHeaderFooterView using its class type
    func register<T: UIView>(_ headerFooterViewClass: T.Type) where T: NibLoadableView {
        let nib = UINib(nibName: String(describing: headerFooterViewClass), bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: String(describing: headerFooterViewClass))
    }
    
    // Dequeue a reusable header footer view using its class type
    func dequeueReusableHeaderFooterView<T: UIView>() -> T? {
        return self.dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as? T
    }
}


extension UITableView {
    
    func registerHeader<T: UIView>(_ headerClass: T.Type) where T: NibLoadableView {
            let nib = UINib(nibName: headerClass.nibName, bundle: nil)
            self.register(nib, forHeaderFooterViewReuseIdentifier: headerClass.nibName)
        }
        
      

    // Register a UITableViewCell using its class type
    func register<T: UITableViewCell>(_ cellClass: T.Type) where T: NibLoadableView {
        let nib = UINib(nibName: String(describing: cellClass), bundle: nil)
        self.register(nib, forCellReuseIdentifier: String(describing: cellClass))
    }

    // Dequeue a reusable cell using its class type
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(String(describing: T.self))")
        }
        return cell
    }
}

protocol NibLoadableView: AnyObject {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

//MARK: - UICollectionview

extension UICollectionView {
    
    /// Scrolls to the footer of a specific section.
    /// - Parameters:
    ///   - section: The section index of the footer.
    ///   - animated: A Boolean value that indicates whether the scrolling should be animated.
    func scrollToFooter(inSection section: Int, animated: Bool, itemCount : Int) {
        // Ensure the collection view has the specified section
        guard numberOfSections > section else {
            return
        }
        
        // Create an index path for the footer
        let footerIndexPath = IndexPath(item: itemCount, section: section)
        
        // Scroll to the footer (to ensure visibility, you might need to adjust the content offset)
        scrollToItem(at: footerIndexPath, at: .bottom, animated: animated)
    }
}

extension UICollectionView {
    
    /// Scrolls to the last item in the collection view.
    /// - Parameter animated: A Boolean value that indicates whether the scrolling should be animated.
    func scrollToLastItem(animated: Bool) {
        // Ensure the collection view has items
        guard numberOfSections > 0, numberOfItems(inSection: numberOfSections - 1) > 0 else {
            return
        }
        
        // Calculate the index path of the last item
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: numberOfSections - 1) - 1, section: numberOfSections - 1)
        
        // Scroll to the last item
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: animated)
    }
}

extension UICollectionView {
    
    func cellForItem<T: UICollectionViewCell>(at indexPath: IndexPath, as type: T.Type) -> T? {
        return self.cellForItem(at: indexPath) as? T
    }
    
    // Animation for inserting items
    func animateItemsInsert(at indexPaths: [IndexPath], with animationType: CollectionViewAnimationType) {
        performBatchUpdates {
            insertItems(at: indexPaths)
            animateItems(at: indexPaths, with: animationType)
        }
    }
    
    // Animation for deleting items
    func animateItemsDelete(at indexPaths: [IndexPath], with animationType: CollectionViewAnimationType) {
        performBatchUpdates {
            deleteItems(at: indexPaths)
            animateItems(at: indexPaths, with: animationType)
        }
    }
    
    // Animation for reloading items
    func animateItemsReload(at indexPaths: [IndexPath], with animationType: CollectionViewAnimationType) {
        performBatchUpdates {
            reloadItems(at: indexPaths)
            animateItems(at: indexPaths, with: animationType)
        }
    }
    
    // Apply animations to items
    private func animateItems(at indexPaths: [IndexPath], with animationType: CollectionViewAnimationType) {
        for indexPath in indexPaths {
            let cell = cellForItem(at: indexPath)
            applyAnimation(to: cell, with: animationType)
        }
    }
    
    // Apply the specific animation to a cell
    private func applyAnimation(to cell: UICollectionViewCell?, with animationType: CollectionViewAnimationType) {
        guard let cell = cell else { return }
        
        switch animationType {
        case .fadeIn:
            cell.alpha = 0
            UIView.animate(withDuration: 0.3) {
                cell.alpha = 1
            }
        case .scaleUp:
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3) {
                cell.transform = CGAffineTransform.identity
            }
        case .scaleDown:
            cell.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            UIView.animate(withDuration: 0.3) {
                cell.transform = CGAffineTransform.identity
            }
        case .rotate:
            cell.transform = CGAffineTransform(rotationAngle: .pi)
            UIView.animate(withDuration: 0.3) {
                cell.transform = CGAffineTransform.identity
            }
        case .flipFromLeft:
            UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        case .flipFromRight:
            UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
        case .flipFromTop:
            UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromTop, animations: nil, completion: nil)
        case .flipFromBottom:
            UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromBottom, animations: nil, completion: nil)
        case .slideInFromLeft:
            cell.transform = CGAffineTransform(translationX: -cell.frame.width, y: 0)
            UIView.animate(withDuration: 0.3) {
                cell.transform = CGAffineTransform.identity
            }
        case .slideInFromRight:
            cell.transform = CGAffineTransform(translationX: cell.frame.width, y: 0)
            UIView.animate(withDuration: 0.3) {
                cell.transform = CGAffineTransform.identity
            }
        case .slideInFromTop:
            cell.transform = CGAffineTransform(translationX: 0, y: -cell.frame.height)
            UIView.animate(withDuration: 0.3) {
                cell.transform = CGAffineTransform.identity
            }
        case .slideInFromBottom:
            cell.transform = CGAffineTransform(translationX: 0, y: cell.frame.height)
            UIView.animate(withDuration: 0.3) {
                cell.transform = CGAffineTransform.identity
            }
        case .bounce:
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
        case .fadeSlideFromLeft:
            cell.alpha = 0
            cell.transform = CGAffineTransform(translationX: -cell.frame.width, y: 0)
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1
                cell.transform = CGAffineTransform.identity
            }
        case .fadeSlideFromRight:
            cell.alpha = 0
            cell.transform = CGAffineTransform(translationX: cell.frame.width, y: 0)
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1
                cell.transform = CGAffineTransform.identity
            }
        case .fadeSlideFromTop:
            cell.alpha = 0
            cell.transform = CGAffineTransform(translationX: 0, y: -cell.frame.height)
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1
                cell.transform = CGAffineTransform.identity
            }
        case .fadeSlideFromBottom:
            cell.alpha = 0
            cell.transform = CGAffineTransform(translationX: 0, y: cell.frame.height)
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1
                cell.transform = CGAffineTransform.identity
            }
        case .zoomInBounce:
            cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    cell.transform = CGAffineTransform.identity
                }
            }
        case .zoomOutBounce:
            cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    cell.transform = CGAffineTransform.identity
                }
            }
        case .curlUp:
            UIView.transition(with: cell, duration: 0.3, options: .transitionCurlUp, animations: nil, completion: nil)
        case .curlDown:
            UIView.transition(with: cell, duration: 0.3, options: .transitionCurlDown, animations: nil, completion: nil)
        }
    }
}

// Enum to define different animation types
enum CollectionViewAnimationType {
    case fadeIn
    case scaleUp
    case scaleDown
    case rotate
    case flipFromLeft
    case flipFromRight
    case flipFromTop
    case flipFromBottom
    case slideInFromLeft
    case slideInFromRight
    case slideInFromTop
    case slideInFromBottom
    case bounce
    case fadeSlideFromLeft
    case fadeSlideFromRight
    case fadeSlideFromTop
    case fadeSlideFromBottom
    case zoomInBounce
    case zoomOutBounce
    case curlUp
    case curlDown
}


extension UICollectionView {
    
    func animateSection(_ section: Int, with animationType: CollectionViewAnimationType) {
        // Reload the section with a fade animation
        reloadSections(IndexSet(integer: section))
        
        // Get all visible cells in the section
        let visibleCells = self.visibleCells(in: section)
        
        // Apply the animation to each cell
        for cell in visibleCells {
            applyAnimation(to: cell, with: animationType)
        }
    }
    
    private func visibleCells(in section: Int) -> [UICollectionViewCell] {
        return self.visibleCells.filter { indexPath(for: $0)?.section == section }
    }
    
    private func applyAnimationToCV(to cell: UICollectionViewCell?, with animationType: CollectionViewAnimationType) {
        guard let cell = cell else { return }
        
        switch animationType {
        case .fadeIn:
            cell.alpha = 0
            UIView.animate(withDuration: 0.3) {
                cell.alpha = 1
            }
        // Add other cases from the previous animation list as needed
        default:
            break
        }
    }
}

extension UICollectionView {
    
    func applyScrollingAnimation(to cell: UICollectionViewCell, at indexPath: IndexPath, with animationType: ScrollingAnimationType) {
        switch animationType {
        case .fadeIn:
            cell.alpha = 0
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1
            }
        case .slideInFromLeft:
            cell.transform = CGAffineTransform(translationX: -self.bounds.width, y: 0)
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
            }
        case .slideInFromRight:
            cell.transform = CGAffineTransform(translationX: self.bounds.width, y: 0)
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
            }
        case .slideInFromTop:
            cell.transform = CGAffineTransform(translationX: 0, y: -self.bounds.height)
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
            }
        case .slideInFromBottom:
            cell.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
            }
        case .scaleUp:
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
            }
        case .scaleDown:
            cell.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
            }
        case .rotate:
            cell.transform = CGAffineTransform(rotationAngle: .pi)
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
            }
        case .flipFromLeft:
            UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        case .flipFromRight:
            UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
        case .flipFromTop:
            UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromTop, animations: nil, completion: nil)
        case .flipFromBottom:
            UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromBottom, animations: nil, completion: nil)
        case .bounce:
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
        case .fadeSlideInFromLeft:
            cell.alpha = 0
            cell.transform = CGAffineTransform(translationX: -self.bounds.width, y: 0)
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1
                cell.transform = CGAffineTransform.identity
            }
        case .fadeSlideInFromRight:
            cell.alpha = 0
            cell.transform = CGAffineTransform(translationX: self.bounds.width, y: 0)
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1
                cell.transform = CGAffineTransform.identity
            }
        case .fadeSlideInFromTop:
            cell.alpha = 0
            cell.transform = CGAffineTransform(translationX: 0, y: -self.bounds.height)
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1
                cell.transform = CGAffineTransform.identity
            }
        case .fadeSlideInFromBottom:
            cell.alpha = 0
            cell.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1
                cell.transform = CGAffineTransform.identity
            }
        case .zoomInBounce:
            cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.5, animations: {
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    cell.transform = CGAffineTransform.identity
                }
            }
        case .zoomOutBounce:
            cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.5, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    cell.transform = CGAffineTransform.identity
                }
            }
        case .curlUp:
            UIView.transition(with: cell, duration: 0.5, options: .transitionCurlUp, animations: nil, completion: nil)
        case .curlDown:
            UIView.transition(with: cell, duration: 0.5, options: .transitionCurlDown, animations: nil, completion: nil)
        case .wave:
            cell.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
            UIView.animate(withDuration: 0.5, delay: 0.1 * Double(indexPath.row), options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
        case .shake:
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: cell.center.x - 10, y: cell.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: cell.center.x + 10, y: cell.center.y))
            cell.layer.add(animation, forKey: "position")
        case .dissolve:
            UIView.transition(with: cell, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        case .flash:
            cell.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.autoreverse, .repeat], animations: {
                UIView.setAnimationRepeatCount(2)
                cell.alpha = 1
            }, completion: nil)
        case .heartbeat:
            cell.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(withDuration: 0.3, delay: 0, options: [.autoreverse, .repeat], animations: {
                UIView.setAnimationRepeatCount(2)
                cell.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { _ in
                cell.transform = CGAffineTransform.identity
            }
        case .spin:
            UIView.animate(withDuration: 0.5, animations: {
                cell.transform = CGAffineTransform(rotationAngle: .pi)
            }) { _ in
                cell.transform = CGAffineTransform.identity
            }
        case .floatIn:
            cell.transform = CGAffineTransform(translationX: 0, y: -20)
            cell.alpha = 0
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
                cell.alpha = 1
            }
        case .squeezeIn:
            cell.transform = CGAffineTransform(scaleX: 1.5, y: 0.5)
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
            }
        case .squeezeOut:
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 1.5)
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
            }
        }
    }
}

// Enum for different scrolling animation types
enum ScrollingAnimationType {
    case fadeIn
    case slideInFromLeft
    case slideInFromRight
    case slideInFromTop
    case slideInFromBottom
    case scaleUp
    case scaleDown
    case rotate
    case flipFromLeft
    case flipFromRight
    case flipFromTop
    case flipFromBottom
    case bounce
    case fadeSlideInFromLeft
    case fadeSlideInFromRight
    case fadeSlideInFromTop
    case fadeSlideInFromBottom
    case zoomInBounce
    case zoomOutBounce
    case curlUp
    case curlDown
    case wave
    case shake
    case dissolve
    case flash
    case heartbeat
    case spin
    case floatIn
    case squeezeIn
    case squeezeOut
}



extension UICollectionView {

    // Register a UICollectionViewCell using its class type
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) where T: NibLoadableView {
        let nib = UINib(nibName: String(describing: cellClass), bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: String(describing: cellClass))
    }

    // Dequeue a reusable cell using its class type
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(String(describing: T.self))")
        }
        return cell
    }
}

extension UICollectionView {
    // Register a supplementary view using its class type
    func registerSupplementaryView<T: UICollectionReusableView>(_ viewClass: T.Type, forSupplementaryViewOfKind kind: String) where T: NibLoadableView {
        let nib = UINib(nibName: String(describing: viewClass), bundle: nil)
        self.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: viewClass))
    }

    // Dequeue a reusable supplementary view using its class type
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> T {
        guard let view = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue supplementary view with identifier: \(String(describing: T.self))")
        }
        return view
    }
}


extension UICollectionView {
    
    func itemSize(forColumns columns: Int, withSpacing spacing: CGFloat, padding: CGFloat = 20.0, aspectRatio: CGFloat = 1.0) -> CGSize {
        // Adjust available width by subtracting left and right padding
        let availableWidth = self.bounds.width - self.contentInset.left - self.contentInset.right  - (spacing * CGFloat(columns - 1))
        let itemWidth = (availableWidth / CGFloat(columns))
        let itemHeight = itemWidth / aspectRatio
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
//MARK: - Flowlayout

extension UICollectionViewFlowLayout {

    func setColumns(numberOfColumns: Int, itemSpacing: CGFloat = 10, lineSpacing: CGFloat = 10, sectionInset: UIEdgeInsets = .zero) {
        guard let collectionView = self.collectionView else {
            return
        }
        
        
        let totalItemSpacing = itemSpacing * CGFloat(numberOfColumns - 1)
        let totalInset = sectionInset.left + sectionInset.right
        let availableWidth = collectionView.bounds.width - totalItemSpacing - totalInset
        
        // Calculate the item width based on the number of columns
        let itemWidth = availableWidth / CGFloat(numberOfColumns)
        
        // Set the item size and spacing properties
        self.itemSize = CGSize(width: itemWidth, height: itemWidth) // Adjust height as needed
        self.minimumInteritemSpacing = itemSpacing
        self.minimumLineSpacing = lineSpacing
        self.sectionInset = sectionInset
    }
}


extension UITableView {
    
    func addPullToRefresh(action: @escaping () -> Void) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
        
        // Associate the action with the refresh control
        objc_setAssociatedObject(self, &AssociatedKeys.actionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func startRefreshing() {
        if let refreshControl = self.refreshControl {
            refreshControl.beginRefreshing()
            if let scrollView = self.superview as? UIScrollView {
                scrollView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.height), animated: true)
            }
        }
    }
    
    func stopRefreshing(completion: (() -> Void)? = nil) {
        if let refreshControl = self.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            completion?()
        }
    }
    
    @objc private func handleRefreshControl(_ sender: UIRefreshControl) {
        if let action = objc_getAssociatedObject(self, &AssociatedKeys.actionKey) as? () -> Void {
            action()
        }
    }
}

// Extension for UICollectionView
extension UICollectionView {
    
    func addPullToRefresh(action: @escaping () -> Void) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
        
        // Associate the action with the refresh control
        objc_setAssociatedObject(self, &AssociatedKeys.actionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func startRefreshing() {
        if let refreshControl = self.refreshControl {
            refreshControl.beginRefreshing()
            if let scrollView = self.superview as? UIScrollView {
                scrollView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.height), animated: true)
            }
        }
    }
    
    func stopRefreshing(completion: (() -> Void)? = nil) {
        if let refreshControl = self.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            completion?()
        }
    }
    
    @objc private func handleRefreshControl(_ sender: UIRefreshControl) {
        if let action = objc_getAssociatedObject(self, &AssociatedKeys.actionKey) as? () -> Void {
            action()
        }
    }
}

// Associated Object Key for storing the action
private struct AssociatedKeys {
    static var actionKey = "actionKey"
}

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}
