//
//  Array+Safe.swift
//  Pods
//
//  Created by Millman YANG on 2017/7/6.
//
//

import Foundation
import UIKit

extension Array {
    subscript(safe idx: Int) -> Element? {
        return indices ~= idx ? self[idx] : nil
    }
}
