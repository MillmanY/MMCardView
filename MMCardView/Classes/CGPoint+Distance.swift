//
//  CGPoint+Distance.swift
//  Pods
//
//  Created by Millman YANG on 2017/7/6.
//
//

import Foundation
import UIKit
extension CGPoint {
    func distance(point: CGPoint) -> CGFloat {
        let x = (point.x - self.x)
        let y = (point.y - self.y)
        return CGFloat(sqrt((x*x)+(y*y)))
    }
}
