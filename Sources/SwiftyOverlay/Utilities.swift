//
//  Utilities.swift
//  SwiftyGuideOverlay
//
//  Created by Saeid Basirnia on 1/16/18.
//  Copyright © 2018 Saeid Basirnia. All rights reserved.
//

import UIKit

enum LineDirection: UInt32 {
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
extension GDOverlay {
    private var keyWindow: UIWindow? {
        var keyWindow: UIWindow?
        if #available(iOS 13.0, *) {
            keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?.windows
                .filter { $0.isKeyWindow }.first
        } else {
            keyWindow = UIApplication.shared.keyWindow
        }
        return keyWindow
    }
    
    private var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return keyWindow?.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    var topView: UIView? {
        return keyWindow
    }
    
    func calculateNavHeight(_ vc: UIViewController) -> CGFloat {
        guard let navigationController = vc.navigationController else { return 0 }
        return navigationController.navigationBar.frame.height + statusBarHeight
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

extension UIBezierPath {
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
    
    private func calculatePointFromPoint(point: CGPoint, angle: CGFloat, distance: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(Float(point.x) + cosf(Float(angle)) * Float(distance)), y: CGFloat(Float(point.y) + sinf(Float(angle)) * Float(distance)))
    }
}
