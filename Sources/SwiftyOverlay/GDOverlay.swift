//
//  GDOverlay.swift
//  SwiftyGuideOverlay
//
//  Created by Saeid Basirnia on 8/16/16.
//  Copyright © 2016 Saeidbsn. All rights reserved.
//

import UIKit

public protocol SkipOverlayDelegate: AnyObject {
    func onSkipSignal()
}

public final class GDOverlay: UIView {
    //MARK: - Attributes
    fileprivate var _backColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    
    public var backColor: UIColor {
        get {
            return _backColor
        }
        set {
            _backColor = newValue
        }
    }
    
    fileprivate var _boxBackColor: UIColor = UIColor.white.withAlphaComponent(0.05)
    public var boxBackColor: UIColor {
        get {
            return _boxBackColor
        }
        set {
            _boxBackColor = newValue
        }
    }
    
    fileprivate var _boxBorderColor: UIColor = UIColor.white
    public var boxBorderColor: UIColor {
        get {
            return _boxBorderColor
        }
        set {
            _boxBorderColor = newValue
        }
    }
    
    fileprivate var _showBorder: Bool = true
    public var showBorder: Bool {
        get {
            return _showBorder
        }
        set {
            _showBorder = newValue
        }
    }
    
    fileprivate var _lineType: LineType = .dash_bubble
    public var lineType: LineType {
        get {
            return _lineType
        }
        set {
            _lineType = newValue
        }
    }
    
    fileprivate var _arrowColor: UIColor = UIColor.white
    public var arrowColor: UIColor {
        get {
            return _arrowColor
        }
        set {
            _arrowColor = newValue
        }
    }
    
    fileprivate var _headColor: UIColor = UIColor.white
    public var headColor: UIColor {
        get {
            return _headColor
        }
        set {
            _headColor = newValue
        }
    }
    
    fileprivate var _arrowWidth: CGFloat = 2.0
    public var arrowWidth: CGFloat {
        get {
            return _arrowWidth
        }
        set {
            _arrowWidth = newValue
        }
    }
    
    fileprivate var _headRadius: CGFloat = 4.0
    public var headRadius: CGFloat {
        get {
            return _headRadius
        }
        set {
            _headRadius = newValue
        }
    }
    
    fileprivate var _highlightView: Bool = false
    public var highlightView: Bool {
        get {
            return _highlightView
        }
        set {
            _highlightView = newValue
        }
    }
    
    //MARK: - Self Init
    public weak var delegate: SkipOverlayDelegate? = nil
    fileprivate var helpView: UIView!
    
    public init(){
        super.init(frame: CGRect.zero)
        
        self.frame = self.topView?.frame ?? CGRect.zero
        self.backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func calculateCenter() -> CGPoint {
        let targetRect = helpView.convert(helpView.bounds , to: topView)
        return targetRect.center
    }
    
    private func initViews(_ circle: Bool, textOnly: Bool = false) {
        if !textOnly {
            let targetCenter: CGPoint = calculateCenter()
            self.createBackgroundView()
            self.createContainerView()
            
            self.topView?.addSubview(self)
            setupContainerViewConstraints(to: targetCenter)
            
            layoutIfNeeded()
            if _highlightView {
                self.unmaskView(targetCenter, isCircle: circle)
            }
            
            self.createTargetView(center: targetCenter)
        } else {
            self.createBackgroundView()
            self.createContainerView()
            
            self.topView?.addSubview(self)
            setupContainerViewConstraints()
            
            layoutIfNeeded()
        }
    }
    
    public func drawOverlay(to barButtonItem: UIBarButtonItem, desc: NSAttributedString){
        if let barView = barButtonItem.value(forKey: "view") as? UIView {
            let barFrame = barView.frame
            let windowRect = barView.convert(barFrame, to: topView)
            let v = UIView()
            v.frame = windowRect
            self.addSubview(v)
            helpView = v
        }
        
        descLabel.attributedText = desc
        initViews(true)
    }
    
    public func drawOverlay(to tabbarView: UITabBar, item: Int, desc: NSAttributedString){
        var vs = tabbarView.subviews.filter { $0.isUserInteractionEnabled }
        vs = vs.sorted(by: { $0.frame.minX < $1.frame.minX })
        
        var windowRect = vs[item].convert(vs[0].frame, to: topView)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            windowRect.origin.x = vs[item].frame.minX
            windowRect.size.width = vs[item].frame.width
        }
        
        let v = UIView()
        v.frame = windowRect
        self.addSubview(v)
        
        helpView = v
        
        descLabel.attributedText = desc
        initViews(false)
    }
    
    public func drawOverlay(to tableView: UITableView, section: Int, row: Int, desc: NSAttributedString) {
        let indexPath: IndexPath = IndexPath(row: row, section: section)
        let tableRect = tableView.rectForRow(at: indexPath)
        let windowRect = tableView.convert(tableRect, to: topView)
        
        let v = UIView()
        v.frame = windowRect
        self.addSubview(v)
        
        helpView = v
        
        descLabel.attributedText = desc
        initViews(false)
    }
    
    
    public func drawOverlay(desc: NSAttributedString) {
        initViews(false, textOnly: true)
        descLabel.attributedText = desc
    }
    
    public func drawOverlay(to view: UIView, desc: NSAttributedString, isCircle: Bool = true) {
        let windowRect = view.convert(view.bounds , to: topView)
        let v = UIView()
        v.frame = windowRect
        self.addSubview(v)
        
        helpView = v
        
        initViews(isCircle)
        descLabel.attributedText = desc
    }
    
    //MARK: - Background View
    fileprivate var backgroundView: UIView!
    private func createBackgroundView(){
        backgroundView = UIView()
        backgroundView.frame = self.frame
        backgroundView.isUserInteractionEnabled = true
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.backgroundColor = _backColor
        
        self.addSubview(backgroundView)
        self.setupGestures()
    }
    
    private func setupGestures() {
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(gotoNext(_:)))
        tapGest.numberOfTapsRequired = 1
        tapGest.numberOfTouchesRequired = 1
        
        self.backgroundView.addGestureRecognizer(tapGest)
    }
    
    @objc private func gotoNext(_ sender: UIGestureRecognizer) {
        self.removeFromSuperview()
        self.backgroundView.removeFromSuperview()
        self.delegate?.onSkipSignal()
    }
    
    //MARK: - Description Label
    fileprivate var descLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.sizeToFit()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        return lbl
    }()
    
    private lazy var getLabelHeight: CGFloat = {
        let lblHeight = self.descLabel.frame.height
        return lblHeight
    }()
    
    //MARK: - Container View
    fileprivate var contView: UIView!
    private func createContainerView() {
        guard let topView = topView else { return }
                
        contView = UIView()
        contView.frame = CGRect(x: 0, y: 0, width: topView.frame.width - 60, height: 50)
        contView.backgroundColor = _boxBackColor
        if _showBorder {
            contView.layer.borderColor = _boxBorderColor.cgColor
            contView.layer.borderWidth = 2
            contView.layer.cornerRadius = 5
        }
        contView.translatesAutoresizingMaskIntoConstraints = false
        contView.addSubview(descLabel)
        backgroundView.addSubview(contView)
        setupLabelConstraints()
    }
    
    //MARK: - Tools
    private func unmaskView(_ targetPoint: CGPoint, isCircle: Bool) {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        
        let radius: CGFloat = isCircle ? (max(helpView.frame.width + 20, helpView.frame.height + 10)) / 2 : 0
        let clipPath: CGPath = UIBezierPath(roundedRect: CGRect(x: helpView.frame.origin.x - 20, y: helpView.frame.origin.y - 10, width: helpView.frame.width + 40, height: helpView.frame.height + 20), cornerRadius: radius).cgPath
        
        path.addPath(clipPath)
        path.addRect(CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        backgroundView.layer.mask = maskLayer
        backgroundView.clipsToBounds = false
    }
}

// MARK: - setup constraints
extension GDOverlay {
    fileprivate func setupLabelConstraints(){
        descLabel.leftAnchor.constraint(equalTo: contView.leftAnchor, constant: 10.0).isActive = true
        descLabel.rightAnchor.constraint(equalTo: contView.rightAnchor, constant: -10.0).isActive = true
        descLabel.topAnchor.constraint(equalTo: contView.topAnchor, constant: 10.0).isActive = true
        descLabel.bottomAnchor.constraint(equalTo: contView.bottomAnchor, constant: -10.0).isActive = true
    }
    
    fileprivate func setupContainerViewConstraints() {
        let centerX = contView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0)
        centerX.isActive = true
        let centerY = contView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0)
        centerY.isActive = true
        
        let right = contView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        right.isActive = true
        let left = contView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16)
        left.isActive = true
        
        topView?.addConstraints([centerY, centerX, right, left])
    }
    
    fileprivate func setupContainerViewConstraints(to point: CGPoint) {
        let section = setSection(point)
        let consts = setSectionPoint(section)
        
        topView?.addConstraints(consts)
    }
}

//MARK: - Create and calculate points
extension GDOverlay{
    private func calcCenterPoint(_ start: CGPoint, end: CGPoint) -> CGPoint {
        let x = (start.x + end.x) / 2
        let y = (start.y + end.y) / 2
        
        return CGPoint(x: x, y: y)
    }
    
    fileprivate func createTargetView(center: CGPoint) {
        let section = setSection(center)
        var startPoint: CGPoint!
        var endPoint: CGPoint!
        var controlPoint: CGPoint!
        
        let dir = LineDirection.randomDir
        let offsetTop: CGFloat = highlightView ? 20.0 : 0.0
        let offsetBottom: CGFloat = highlightView ? -20.0 : 0.0
        
        switch section {
        case 0, 1:
            if dir == .left {
                startPoint = CGPoint(x: contView.frame.midX - 50, y: contView.frame.minY - 10)
                endPoint = CGPoint(x: helpView.frame.midX, y: helpView.frame.maxY + offsetTop)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x - 50, y: cp.y)
            } else {
                startPoint = CGPoint(x: contView.frame.midX, y: contView.frame.minY - 20)
                endPoint = CGPoint(x: helpView.frame.midX + 25, y: helpView.frame.maxY + offsetTop)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x + 50, y: cp.y)
            }
        case 2:
            if dir == .left {
                startPoint = CGPoint(x: contView.frame.midX + contView.frame.midX / 4, y: contView.frame.minY - 10)
                endPoint = CGPoint(x: helpView.frame.minX + 5, y: helpView.frame.maxY + offsetTop)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x - 50, y: cp.y)
            } else {
                startPoint = CGPoint(x: contView.frame.midX + contView.frame.midX / 4, y: contView.frame.minY - 10)
                endPoint = CGPoint(x: helpView.frame.midX + 5, y: helpView.frame.maxY + offsetTop)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x + 50, y: cp.y)
            }
        case 3:
            if dir == .left {
                startPoint = CGPoint(x: contView.frame.midX - contView.frame.midX / 4, y: contView.frame.maxY + 10)
                endPoint = CGPoint(x: helpView.frame.midX, y: helpView.frame.minY + offsetBottom)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x - 50, y: cp.y)
            } else {
                startPoint = CGPoint(x: contView.frame.midX - contView.frame.midX / 4, y: contView.frame.maxY + 10)
                endPoint = CGPoint(x: helpView.frame.maxX, y: helpView.frame.minY + offsetBottom)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x + 50, y: cp.y)
            }
        case 4:
            if dir == .left {
                startPoint = CGPoint(x: contView.frame.maxX - 50, y: contView.frame.maxY + 8)
                endPoint = CGPoint(x: helpView.frame.maxX - 50, y: helpView.frame.minY + offsetBottom)

                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x + 50, y: cp.y)
            } else {
                startPoint = CGPoint(x: contView.frame.midX, y: contView.frame.maxY + 10)
                endPoint = CGPoint(x: helpView.frame.midX - 25, y: helpView.frame.minY + offsetBottom)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x - 50, y: cp.y)
            }
        default:
            break
        }
        let lineShape: CAShapeLayer!
        var bubbleShape: CAShapeLayer?
        
        switch _lineType {
        case .dash_bubble:
            lineShape = drawLine(startPoint: startPoint, endPoint: endPoint, controlPoint: controlPoint)
            lineShape.lineDashPattern = [3, 6]
            bubbleShape = drawHead(endPoint)
        case .line_arrow:
            lineShape = drawArrow(startPoint: startPoint, endPoint: endPoint, controlPoint: controlPoint)
            lineShape.lineDashPattern = nil
        case .line_bubble:
            lineShape = drawLine(startPoint: startPoint, endPoint: endPoint, controlPoint: controlPoint)
            lineShape.lineDashPattern = nil
            bubbleShape = drawHead(endPoint)
        }
        
        self.backgroundView.layer.addSublayer(lineShape)
        if let bs = bubbleShape{
            self.backgroundView.layer.addSublayer(bs)
        }
        animateArrow(lineShape)
    }
    
    fileprivate func setSection(_ targetPoint: CGPoint) -> Int {
        guard let topView = topView else { return 0 }
        
        let centerPoint: CGPoint = topView.center
        if targetPoint == centerPoint {
            return 0
        } else if targetPoint.x <= centerPoint.x && targetPoint.y < centerPoint.y {
            return 1
        } else if targetPoint.x < centerPoint.x && targetPoint.y > centerPoint.y {
            return 3
        } else if targetPoint.x > centerPoint.x && targetPoint.y < centerPoint.y {
            return 2
        } else if targetPoint.x >= centerPoint.x && targetPoint.y > centerPoint.y {
            return 4
        } else {
            return 1
        }
    }
    
    fileprivate func setSectionPoint(_ section: Int) -> [NSLayoutConstraint] {
        guard let topView = topView else { return [] }
        
        let dynamicSpace = CGFloat(arc4random_uniform(20) + 100)
        switch section {
        case 0, 1, 2:
            let x = contView.centerXAnchor.constraint(equalTo: topView.centerXAnchor, constant: 0.0)
            x.isActive = true
            let y = contView.topAnchor.constraint(equalTo: helpView.bottomAnchor, constant: dynamicSpace)
            y.isActive = true
            
            let right = contView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
            right.isActive = true
            let left = contView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16)
            left.isActive = true

            return [x, y, left, right]
        case 3, 4:
            let x = contView.centerXAnchor.constraint(equalTo: topView.centerXAnchor, constant: 0.0)
            x.isActive = true
            let y = contView.bottomAnchor.constraint(equalTo: helpView.topAnchor, constant: -dynamicSpace)
            y.isActive = true
            
            let right = contView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
            right.isActive = true
            let left = contView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16)
            left.isActive = true

            return [x, y, left, right]
        default:
            return []
        }
    }
}

//MARK: - Drawing lines
extension GDOverlay {
    fileprivate func drawArrow(startPoint: CGPoint, endPoint: CGPoint, controlPoint: CGPoint) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = _arrowColor.cgColor
        shapeLayer.lineWidth = _arrowWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        let path = UIBezierPath()
        path.addArrowForm(point: endPoint, controlPoint: controlPoint, width: 5, height: 10)
        path.addQuadCurve(to: startPoint, controlPoint: controlPoint)
        shapeLayer.path = path.cgPath
        
        return shapeLayer
    }
    
    fileprivate func drawLine(startPoint: CGPoint, endPoint: CGPoint, controlPoint: CGPoint) -> CAShapeLayer {
        let bez = UIBezierPath()
        bez.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        bez.addQuadCurve(to: CGPoint(x: endPoint.x, y: endPoint.y), controlPoint: controlPoint)
        
        let shape = CAShapeLayer()
        shape.path = bez.cgPath
        shape.strokeColor = _arrowColor.cgColor
        shape.fillColor = nil
        shape.lineWidth = _arrowWidth
        shape.lineCap = CAShapeLayerLineCap.round
        shape.lineJoin = CAShapeLayerLineJoin.miter
        shape.strokeStart = 0.0
        shape.strokeEnd = 0.0
        
        return shape
    }
    
    fileprivate func drawHead(_ endPoint: CGPoint) -> CAShapeLayer {
        let circlePath: UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: endPoint.x, y: endPoint.y), radius: _headRadius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let circleShape = CAShapeLayer()
        circleShape.path = circlePath.cgPath
        circleShape.fillColor = _headColor.cgColor
        
        return circleShape
    }
    
    fileprivate func animateArrow(_ shape1: CAShapeLayer) {
        let arrowAnim = CABasicAnimation(keyPath: "strokeEnd")
        arrowAnim.fromValue = 0.0
        arrowAnim.toValue = 1.0
        arrowAnim.duration = 0.5
        arrowAnim.autoreverses = false
        arrowAnim.fillMode = CAMediaTimingFillMode.forwards
        arrowAnim.isRemovedOnCompletion = false
        
        shape1.add(arrowAnim, forKey: nil)
    }
}

