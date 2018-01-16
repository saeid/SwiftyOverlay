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
    
    static func randomDir() -> LineDirection {
        let rand = arc4random_uniform(2)
        return LineDirection(rawValue: rand)!
    }
}

public enum LineType{
    case line_arrow
    case line_bubble
    case dash_arrow
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
        get {
            return CGPoint(x: midX, y: midY)
        }
    }
}

