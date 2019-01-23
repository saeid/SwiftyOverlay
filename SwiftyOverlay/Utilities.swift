//
//  Utilities.swift
//  SwiftyGuideOverlay
//
//  Created by Saeid Basirnia on 1/16/18.
//  Copyright © 2018 Saeid Basirnia. All rights reserved.
//

import UIKit

enum LineDirection: UInt32{
    case left
    case right
    
    static let _count: LineDirection.RawValue = {
        var maxValue: UInt32 = 0
        while let _ = LineDirection(rawValue: maxValue) {
            maxValue += 1
        }
        return maxValue
    }()
    
    static var randomDir: LineDirection {
        let rand = arc4random_uniform(2)
        return LineDirection(rawValue: rand) ?? .left
    }
}

public enum LineType{
    case line_arrow
    case line_bubble
    case dash_bubble
}

// MARK: - helpers
extension GDOverlay{
    var topView: UIView?{
        if let keywindow = UIApplication.shared.keyWindow{
            return keywindow
        }
        return nil
    }
    
    func calculateNavHeight(_ vc: UIViewController) -> CGFloat{
        if let nav = vc.navigationController{
            return nav.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
        }
        return 0
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

extension UIBezierPath{
    func addArrowForm(point: CGPoint, controlPoint: CGPoint, width: CGFloat, height: CGFloat){
        let angle: CGFloat = CGFloat(atan2f(Float(point.y - controlPoint.y), Float(point.x - controlPoint.x)))
        let angleAdjustment: CGFloat = CGFloat(atan2f(Float(width), Float(-height)))
        let distance: CGFloat = CGFloat(hypotf(Float(width), Float(height)))
        
        move(to: point)
        addLine(to: calculatePointFromPoint(point: point, angle: angle + angleAdjustment, distance: distance))
        addLine(to: point)
        addLine(to: calculatePointFromPoint(point: point, angle: angle - angleAdjustment, distance: distance))
        addLine(to: point)
    }
    
    private func calculatePointFromPoint(point: CGPoint, angle: CGFloat, distance: CGFloat) -> CGPoint{
        return CGPoint(x: CGFloat(Float(point.x) + cosf(Float(angle)) * Float(distance)), y: CGFloat(Float(point.y) + sinf(Float(angle)) * Float(distance)))
    }
}
