//
//  IBDESIGNABLE.swift
//  j-lingo
//
//  Created by as on 8/3/24.
//

import UIKit

//MARK: - Curved Header

@IBDesignable
class CurvedHeaderView: UIView {

    enum CurveType: Int {
        case concave
        case convex
        case wave
    }
    
    @IBInspectable var curveType: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var curveHeight: CGFloat = 50.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let width = rect.width
        let height = rect.height
        
        switch CurveType(rawValue: curveType) ?? .concave {
        case .concave:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: height - curveHeight))
            path.addQuadCurve(to: CGPoint(x: width, y: height - curveHeight), controlPoint: CGPoint(x: width / 2, y: height + curveHeight))
            path.addLine(to: CGPoint(x: width, y: 0))
            
        case .convex:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: height - curveHeight))
            path.addQuadCurve(to: CGPoint(x: width, y: height - curveHeight), controlPoint: CGPoint(x: width / 2, y: height - 2 * curveHeight))
            path.addLine(to: CGPoint(x: width, y: 0))
            
        case .wave:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: height - curveHeight))
            path.addCurve(to: CGPoint(x: width, y: height - curveHeight), controlPoint1: CGPoint(x: width / 3, y: height + curveHeight), controlPoint2: CGPoint(x: 2 * width / 3, y: height - 2 * curveHeight))
            path.addLine(to: CGPoint(x: width, y: 0))
        }
        
        path.close()
        UIColor.systemRed.setFill()
        path.fill()
    }
}

//MARK: - Neomorphic cardView

@IBDesignable
class NeomorphicCardView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 10.0 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 10.0 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 10.0, height: 10.0) {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var lightShadowColor: UIColor = UIColor.white.withAlphaComponent(0.7) {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var darkShadowColor: UIColor = UIColor.black.withAlphaComponent(0.2) {
        didSet {
            setupView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.backgroundColor = UIColor.systemBackground
        
        // Light shadow
        let lightShadowLayer = CALayer()
        lightShadowLayer.frame = self.bounds
        lightShadowLayer.backgroundColor = self.backgroundColor?.cgColor
        lightShadowLayer.shadowColor = lightShadowColor.cgColor
        lightShadowLayer.shadowOffset = CGSize(width: -shadowOffset.width, height: -shadowOffset.height)
        lightShadowLayer.shadowOpacity = 1
        lightShadowLayer.shadowRadius = shadowRadius
        lightShadowLayer.cornerRadius = cornerRadius
        self.layer.insertSublayer(lightShadowLayer, at: 0)
        
        // Dark shadow
        let darkShadowLayer = CALayer()
        darkShadowLayer.frame = self.bounds
        darkShadowLayer.backgroundColor = self.backgroundColor?.cgColor
        darkShadowLayer.shadowColor = darkShadowColor.cgColor
        darkShadowLayer.shadowOffset = shadowOffset
        darkShadowLayer.shadowOpacity = 1
        darkShadowLayer.shadowRadius = shadowRadius
        darkShadowLayer.cornerRadius = cornerRadius
        self.layer.insertSublayer(darkShadowLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
}


//MARK: - UIView


@IBDesignable
class DesignableView: UIView {

    // MARK: - Corner Radius
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
            updateGradient() // Update gradient layer to respect corner radius changes
        }
    }

    // MARK: - Border
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    // MARK: - Shadow
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }

    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    // MARK: - Gradient Background
    @IBInspectable var startColor: UIColor? {
        didSet {
            updateGradient()
        }
    }

    @IBInspectable var endColor: UIColor? {
        didSet {
            updateGradient()
        }
    }

    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0) {
        didSet {
            updateGradient()
        }
    }

    @IBInspectable var endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0) {
        didSet {
            updateGradient()
        }
    }

    private var gradientLayer: CAGradientLayer?

    private func updateGradient() {
        if let startColor = startColor, let endColor = endColor {
            if gradientLayer == nil {
                gradientLayer = CAGradientLayer()
                gradientLayer?.frame = bounds
                layer.insertSublayer(gradientLayer!, at: 0)
            }
            gradientLayer?.colors = [startColor.cgColor, endColor.cgColor]
            gradientLayer?.startPoint = startPoint
            gradientLayer?.endPoint = endPoint
            gradientLayer?.cornerRadius = layer.cornerRadius
        } else {
            gradientLayer?.removeFromSuperlayer()
            gradientLayer = nil
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
        gradientLayer?.cornerRadius = layer.cornerRadius
    }
}

@IBDesignable class RoundButton : UIButton{

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    override func prepareForInterfaceBuilder() {
        sharedInit()
    }

    func sharedInit() {
        refreshCorners(value: cornerRadius)
    }

    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }

    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
}

@IBDesignable
class CustomButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    // for shadow
    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var leftImg: UIImage? = nil {
        didSet {
            /* reset title */
            setAttributedTitle()
        }
    }

    @IBInspectable var rightImg: UIImage? = nil {
        didSet {
            /* reset title */
            setAttributedTitle()
        }
    }
    
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setAttributedTitle()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setAttributedTitle()
    }

    private func setAttributedTitle() {
        var attributedTitle = NSMutableAttributedString()

        /* Attaching first image */
        if let leftImg = leftImg {
            let leftAttachment = NSTextAttachment(data: nil, ofType: nil)
            leftAttachment.image = leftImg
            let attributedString = NSAttributedString(attachment: leftAttachment)
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)

            if let title = self.currentTitle {
                mutableAttributedString.append(NSAttributedString(string: title))
            }
            attributedTitle = mutableAttributedString
        }

        /* Attaching second image */
        if let rightImg = rightImg {
            let leftAttachment = NSTextAttachment(data: nil, ofType: nil)
            leftAttachment.image = rightImg
            let attributedString = NSAttributedString(attachment: leftAttachment)
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            attributedTitle.append(mutableAttributedString)
        }

        /* Finally, lets have that two-imaged button! */
        self.setAttributedTitle(attributedTitle, for: .normal)
    }
    
}


@IBDesignable
class CustomView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    // for shadow
    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }
}




@IBDesignable class RoundImageView: UIImageView {
    private var _round = false
    private var _borderColor = UIColor.clear
    private var _borderWidth: CGFloat = 0

    @IBInspectable var round: Bool {
        set {
            _round = newValue
            makeRound()
        }
        get {
            return self._round
        }
    }

    @IBInspectable var borderColor: UIColor {
        set {
            _borderColor = newValue
            setBorderColor()
        }
        get {
            return self._borderColor
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        set {
            _borderWidth = newValue
            setBorderWidth()
        }
        get {
            return self._borderWidth
        }
    }

    override internal var frame: CGRect {
        set {
            super.frame = newValue
            makeRound()
        }
        get {
            return super.frame
        }
    }

    private func makeRound() {
        if self.round {
            self.clipsToBounds = true
            self.layer.cornerRadius = (self.frame.width + self.frame.height) / 4
        } else {
            self.layer.cornerRadius = 0
        }
    }

    private func setBorderColor() {
        self.layer.borderColor = self._borderColor.cgColor
    }

    private func setBorderWidth() {
        self.layer.borderWidth = self._borderWidth
    }
}

extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
    var radiansToDegrees: CGFloat { return self * 180 / .pi }
}
