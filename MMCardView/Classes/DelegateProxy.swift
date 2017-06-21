//
//  DelegateProxy.swift
//  Pods
//
//  Created by Millman YANG on 2017/6/21.
//
//

import UIKit

class DelegateProxy: _DelegateProxy ,UICollectionViewDelegate {
    public init(parentObject: AnyObject) {
        super.init()
        self.parent = parentObject
    }
}
