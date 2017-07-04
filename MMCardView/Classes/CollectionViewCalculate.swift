//
//  CollectionViewCalculate.swift
//  Pods
//
//  Created by Millman YANG on 2017/7/4.
//
//

import UIKit

class CollectionViewCalculate: NSObject {
    fileprivate var sections:Int = 0
    fileprivate var sectionItemsCount = [Int:Int]()
    var totalCount = 0
    
    unowned let collect: UICollectionView
    init(collect: UICollectionView) {
        self.collect = collect
    }
    
    func isNeedUpdate() -> Bool {
        var isUpdate = false
        totalCount = 0
        if self.sections != collect.numberOfSections {
            self.sections = collect.numberOfSections
            sectionItemsCount.removeAll()
        }
        (0..<sections).forEach {
            let count = collect.numberOfItems(inSection: $0)
            if count != sectionItemsCount[$0] {
                sectionItemsCount[$0] = count
                isUpdate = true
            }
            totalCount += count
        }
        return isUpdate
    }
}

var collectionCalculate = "CollectionCalculateKey"
extension UICollectionView {
    var calculate: CollectionViewCalculate {
        set {
            objc_setAssociatedObject(self, &collectionCalculate, newValue, .OBJC_ASSOCIATION_RETAIN)
        } get {
            if let cal = objc_getAssociatedObject(self, &collectionCalculate) as? CollectionViewCalculate {
               return cal
            }
            self.calculate = CollectionViewCalculate(collect: self)
            return self.calculate
        }
    }
}
