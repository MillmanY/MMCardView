//
//  DelegateProxy.swift
//  Pods
//
//  Created by Millman YANG on 2017/6/21.
//
//

import UIKit

class DelegateProxy: NSObject ,UICollectionViewDelegateFlowLayout {
    unowned let parent: AnyObject
    public weak var forwardDelegate: AnyObject?
    public init(parentObject: AnyObject) {
        self.parent = parentObject
        super.init()
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if self.parent.responds(to: aSelector) {
            return parent
        } else if let forward = self.forwardDelegate, forward.responds(to: aSelector){
            return forward
        }
        return super.forwardingTarget(for: aSelector)
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if self.parent.responds(to: aSelector) {
            return true
        } else if let forward = self.forwardDelegate {
            return forward.responds(to: aSelector)
        }
        return super.responds(to: aSelector)
    }
}
