//
//  GDOverlay.swift
//  SwiftyGuideOverlay
//
//  Created by Saeid Basirnia on 8/16/16.
//  Copyright © 2016 Saeidbsn. All rights reserved.
//

import UIKit

protocol SkipOverlayDelegate: class{
    func onSkipSignal()
}

public final class GDOverlay: UIView {
    //MARK: - Attributes
    fileprivate var _backColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    public var backColor: UIColor{
        get{
            return _backColor
        }
        set{
            _backColor = newValue
        }
    }
    
    fileprivate var _boxBackColor: UIColor = UIColor.white.withAlphaComponent(0.05)
    public var boxBackColor: UIColor{
        get{
            return _boxBackColor
        }
        set{
            _boxBackColor = newValue
        }
    }
    
    fileprivate var _boxBorderColor: UIColor = UIColor.white
    public var boxBorderColor: UIColor{
        get{
            return _boxBorderColor
        }
        set{
            _boxBorderColor = newValue
        }
    }
    
    fileprivate var _showBorder: Bool = true
    public var showBorder: Bool{
        get{
            return _showBorder
        }
        set{
            _showBorder = newValue
        }
    }
    
    fileprivate var _lineType: LineType = .dash_bubble
    public var lineType: LineType{
        get{
            return _lineType
        }
        set{
            _lineType = newValue
        }
    }
    
    fileprivate var _labelFont: UIFont = UIFont.boldSystemFont(ofSize: 14)
    public var labelFont: UIFont{
        get{
            return _labelFont
        }
        set{
            _labelFont = newValue
        }
    }
    
    fileprivate var _labelColor: UIColor = UIColor.white
    public var labelColor: UIColor{
        get{
            return _labelColor
        }
        set{
            _labelColor = newValue
        }
    }
    
    fileprivate var _arrowColor: UIColor = UIColor.white
    public var arrowColor: UIColor{
        get{
            return _arrowColor
        }
        set{
            _arrowColor = newValue
        }
    }
    
    fileprivate var _headColor: UIColor = UIColor.white
    public var headColor: UIColor{
        get{
            return _headColor
        }
        set{
            _headColor = newValue
        }
    }
    
    fileprivate var _arrowWidth: CGFloat = 2.0
    public var arrowWidth: CGFloat{
        get{
            return _arrowWidth
        }
        set{
            _arrowWidth = newValue
        }
    }
    
    fileprivate var _headRadius: CGFloat = 4.0
    public var headRadius: CGFloat{
        get{
            return _headRadius
        }
        set{
            _headRadius = newValue
        }
    }
    
    fileprivate var _highlightView: Bool = false
    public var highlightView: Bool{
        get{
            return _highlightView
        }
        set{
            _highlightView = newValue
        }
    }
    
    //MARK: - Self Init
    weak var delegate: SkipOverlayDelegate? = nil
    fileprivate var helpView: UIView!
    
    public init(){
        super.init(frame: CGRect.zero)
        if let topView = topView{
            self.frame = topView.frame
        }
        self.backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func calculateCenter() -> CGPoint {
        let targetRect = helpView.convert(helpView.bounds , to: topView)
        return targetRect.center
    }
    
    private func initViews(_ circle: Bool){
        guard let topView = topView else{
            return
        }
        
        let targetCenter: CGPoint = calculateCenter()
        self.createBackgroundView()
        self.createContainerView()
        
        topView.addSubview(self)
        setupContainerViewConstraints(to: targetCenter)
        
        layoutIfNeeded()
        if _highlightView{
            self.unmaskView(targetCenter, isCircle: circle)
        }
        
        self.createTargetView(center: targetCenter)
    }
    
    public func drawOverlay(to barButtonItem: UIBarButtonItem, desc: String){
        if let barView = barButtonItem.value(forKey: "view") as? UIView {
            let barFrame = barView.frame
            let windowRect = barView.convert(barFrame, to: topView)
            let v = UIView()
            v.frame = windowRect
            self.addSubview(v)
            helpView = v
        }
        
        descLabel.text = desc
        initViews(true)
    }
    
    public func drawOverlay(to tableView: UITableView, section: Int, row: Int, desc: String){
        let indexPath: IndexPath = IndexPath(row: row, section: section)
        let tableRect = tableView.rectForRow(at: indexPath)
        let windowRect = tableView.convert(tableRect, to: topView)
        
        let v = UIView()
        v.frame = windowRect
        self.addSubview(v)
        
        helpView = v
        
        descLabel.text = desc
        initViews(false)
    }
    
    public func drawOverlay(to view: UIView, desc: String, isCircle: Bool = true){
        let windowRect = view.convert(view.bounds , to: topView)
        let v = UIView()
        v.frame = windowRect
        self.addSubview(v)
        
        helpView = v
        
        descLabel.text = desc
        initViews(isCircle)
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
    
    private func setupGestures(){
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(GotoNext(_:)))
        tapGest.numberOfTapsRequired = 1
        tapGest.numberOfTouchesRequired = 1
        
        self.backgroundView.addGestureRecognizer(tapGest)
    }
    
    @objc func GotoNext(_ sender: UIGestureRecognizer){
        self.removeFromSuperview()
        self.backgroundView.removeFromSuperview()
        self.delegate?.onSkipSignal()
    }
    
    //MARK: - Description Label
    fileprivate var descLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 3
        lbl.lineBreakMode = .byWordWrapping
        lbl.sizeToFit()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        return lbl
    }()
    
    private func getLabelHeight() -> CGFloat{
        let lblHeight = descLabel.frame.height
        return lblHeight
    }
    
    //MARK: - Container View
    fileprivate var contView: UIView!
    private func createContainerView(){
        guard let topView = topView else{
            return
        }
        
        self.descLabel.font = _labelFont
        self.descLabel.textColor = _labelColor
        
        contView = UIView()
        contView.frame = CGRect(x: 0, y: 0, width: topView.frame.width - 60, height: 50)
        contView.backgroundColor = _boxBackColor
        if _showBorder{
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
    private func unmaskView(_ targetPoint: CGPoint, isCircle: Bool){
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        
        let radius: CGFloat = isCircle ? (max(helpView.frame.width + 20, helpView.frame.height + 10)) / 2 : 0
        let clipPath: CGPath = UIBezierPath(roundedRect: CGRect(x: helpView.frame.origin.x - 20, y: helpView.frame.origin.y - 10, width: helpView.frame.width + 40, height: helpView.frame.height + 20), cornerRadius: radius).cgPath
        
        path.addPath(clipPath)
        path.addRect(CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        backgroundView.layer.mask = maskLayer
        backgroundView.clipsToBounds = false
    }
}

// MARK: - setup constraints
extension GDOverlay{
    fileprivate func setupLabelConstraints(){
        let left = NSLayoutConstraint(item: self.descLabel, attribute: .left, relatedBy: .equal, toItem: self.contView, attribute: .left, multiplier: 1.0, constant: 10.0)
        let right = NSLayoutConstraint(item: self.descLabel, attribute: .right, relatedBy: .equal, toItem: self.contView, attribute: .right, multiplier: 1.0, constant: -10.0)
        let top = NSLayoutConstraint(item: self.descLabel, attribute: .top, relatedBy: .equal, toItem: self.contView, attribute: .top, multiplier: 1.0, constant: 10.0)
        let bottom = NSLayoutConstraint(item: self.descLabel, attribute: .bottom, relatedBy: .equal, toItem: self.contView, attribute: .bottom, multiplier: 1.0, constant: -10.0)
        
        contView.addConstraints([left, right, top, bottom])
        
        let width = NSLayoutConstraint(item: self.descLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.contView.frame.width - 10)
        self.descLabel.addConstraint(width)
    }
    
    fileprivate func setupContainerViewConstraints(to point: CGPoint){
        guard let topView = topView else{
            return
        }
        let section = setSection(point)
        let consts = setSectionPoint(section)
        
        topView.addConstraints(consts)
    }
}

//MARK: - Create and calculate points
extension GDOverlay{
    private func calcCenterPoint(_ start: CGPoint, end: CGPoint) -> CGPoint{
        let x = (start.x + end.x) / 2
        let y = (start.y + end.y) / 2
        
        return CGPoint(x: x, y: y)
    }
    
    fileprivate func createTargetView(center: CGPoint){
        let section = setSection(center)
        var startPoint: CGPoint!
        var endPoint: CGPoint!
        var controlPoint: CGPoint!
        
        let dir = LineDirection.randomDir()
        let offsetTop: CGFloat = highlightView ? 20.0 : 0.0
        let offsetBottom: CGFloat = highlightView ? -20.0 : 0.0
        
        switch section{
        case 0, 1:
            if dir == .left{
                startPoint = CGPoint(x: contView.frame.midX - 20, y: contView.frame.minY - 10)
                endPoint = CGPoint(x: helpView.frame.midX, y: helpView.frame.maxY + offsetTop)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x - 50, y: cp.y)
            }else{
                startPoint = CGPoint(x: contView.frame.midX, y: contView.frame.minY - 20)
                endPoint = CGPoint(x: helpView.frame.midX + 35, y: helpView.frame.maxY + offsetTop)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x + 50, y: cp.y)
            }
            break
        case 2:
            if dir == .left{
                startPoint = CGPoint(x: contView.frame.midX + contView.frame.midX / 4, y: contView.frame.minY - 10)
                endPoint = CGPoint(x: helpView.frame.minX + 5, y: helpView.frame.maxY + offsetTop)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x - 50, y: cp.y)
            }else{
                startPoint = CGPoint(x: contView.frame.midX + contView.frame.midX / 4, y: contView.frame.minY - 10)
                endPoint = CGPoint(x: helpView.frame.midX + 5, y: helpView.frame.maxY + offsetTop)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x + 50, y: cp.y)
            }
            break
        case 3:
            if dir == .left{
                startPoint = CGPoint(x: contView.frame.midX - contView.frame.midX / 4, y: contView.frame.maxY + 10)
                endPoint = CGPoint(x: helpView.frame.minX + 5, y: helpView.frame.minY + offsetBottom)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x - 50, y: cp.y)
            }else{
                startPoint = CGPoint(x: contView.frame.midX - contView.frame.midX / 4, y: contView.frame.maxY + 10)
                endPoint = CGPoint(x: helpView.frame.maxX, y: helpView.frame.minY + offsetBottom)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x + 50, y: cp.y)
            }
            break
        case 4:
            if dir == .left{
                startPoint = CGPoint(x: contView.frame.midX + contView.frame.midX / 4, y: contView.frame.maxY + 20)
                endPoint = CGPoint(x: helpView.frame.midX + 5, y: helpView.frame.minY + offsetBottom)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x + 50, y: cp.y)
            }else{
                startPoint = CGPoint(x: contView.frame.midX, y: contView.frame.maxY + 10)
                endPoint = CGPoint(x: helpView.frame.minX - 5, y: helpView.frame.midY + offsetBottom)
                
                let cp = calcCenterPoint(startPoint, end: endPoint)
                controlPoint = CGPoint(x: cp.x - 50, y: cp.y)
            }
            break
        default:
            break
        }
        let lineShape = drawLine(startPoint, endPoint: endPoint, controlPoint: controlPoint)
        var bubbleShape: CAShapeLayer?
        
        switch _lineType{
        case .dash_arrow:
            break
        case .dash_bubble:
            lineShape.lineDashPattern = [3, 6]
            bubbleShape = drawHead(endPoint)
            break
        case .line_arrow:
            break
        case .line_bubble:
            lineShape.lineDashPattern = nil
            bubbleShape = drawHead(endPoint)
            break
        }
        
        self.backgroundView.layer.addSublayer(lineShape)
        if let bs = bubbleShape{
            self.backgroundView.layer.addSublayer(bs)
        }
        animateArrow(lineShape)
    }
    
    fileprivate func setSection(_ targetPoint: CGPoint) -> Int{
        guard let topView = topView else{
            return 0
        }
        let centerPoint: CGPoint = topView.center
        
        if targetPoint == centerPoint{
            return 0
        }else if targetPoint.x < centerPoint.x && targetPoint.y < centerPoint.y{
            return 1
        }else if targetPoint.x < centerPoint.x && targetPoint.y > centerPoint.y{
            return 3
        }else if targetPoint.x > centerPoint.x && targetPoint.y < centerPoint.y{
            return 2
        }else if targetPoint.x > centerPoint.x && targetPoint.y > centerPoint.y{
            return 4
        }else{
            return 0
        }
    }
    
    fileprivate func setSectionPoint(_ section: Int) -> [NSLayoutConstraint]{
        let dynamicSpace = CGFloat(arc4random_uniform(20) + 100)
        switch section {
        case 0, 1:
            let x = NSLayoutConstraint(item: self.contView, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1.0, constant: 0)
            let y = NSLayoutConstraint(item: self.contView, attribute: .top, relatedBy: .equal, toItem: self.helpView, attribute: .bottom, multiplier: 1.0, constant: dynamicSpace)
            
            return [x, y]
        case 2:
            let x = NSLayoutConstraint(item: self.contView, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1.0, constant: 0)
            let y = NSLayoutConstraint(item: self.contView, attribute: .top, relatedBy: .equal, toItem: self.helpView, attribute: .bottom, multiplier: 1.0, constant: dynamicSpace)
            
            return [x, y]
        case 3:
            let x = NSLayoutConstraint(item: self.contView, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1.0, constant: 0)
            let y = NSLayoutConstraint(item: self.contView, attribute: .bottom, relatedBy: .equal, toItem: self.helpView, attribute: .top, multiplier: 1.0, constant: -dynamicSpace)
            
            return [x, y]
        case 4:
            let x = NSLayoutConstraint(item: self.contView, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1.0, constant: 0)
            let y = NSLayoutConstraint(item: self.contView, attribute: .bottom, relatedBy: .equal, toItem: self.helpView, attribute: .top, multiplier: 1.0, constant: -dynamicSpace)
            
            return [x, y]
            
        default:
            return []
        }
    }
}

//MARK: - Drawing lines
var control: CGPoint!
extension GDOverlay{
    fileprivate func drawLine(_ startPoint: CGPoint, endPoint: CGPoint, controlPoint: CGPoint) -> CAShapeLayer{
        control = controlPoint
        let bez = UIBezierPath()
        bez.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        bez.addQuadCurve(to: CGPoint(x: endPoint.x, y: endPoint.y), controlPoint: controlPoint)
        
        let shape = CAShapeLayer()
        shape.path = bez.cgPath
        shape.strokeColor = _arrowColor.cgColor
        shape.fillColor = nil
        shape.lineWidth = _arrowWidth
        shape.lineCap = kCALineCapRound
        shape.lineJoin = kCALineJoinMiter
        shape.strokeStart = 0.0
        shape.strokeEnd = 0.0
        
        return shape
    }
    
    fileprivate func drawHead(_ endPoint: CGPoint) -> CAShapeLayer{
        let circlePath: UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: endPoint.x, y: endPoint.y), radius: _headRadius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let circleShape = CAShapeLayer()
        circleShape.path = circlePath.cgPath
        circleShape.fillColor = _headColor.cgColor
        
        return circleShape
    }
    
    fileprivate func animateArrow(_ shape1: CAShapeLayer){
        let arrowAnim = CABasicAnimation(keyPath: "strokeEnd")
        arrowAnim.fromValue = 0.0
        arrowAnim.toValue = 1.0
        arrowAnim.duration = 0.5
        arrowAnim.autoreverses = false
        arrowAnim.fillMode = kCAFillModeForwards
        arrowAnim.isRemovedOnCompletion = false
        
        shape1.add(arrowAnim, forKey: nil)
    }
}


