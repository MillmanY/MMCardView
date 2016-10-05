//
//  CustomCardLayout.swift
//  Pods
//
//  Created by MILLMAN on 2016/9/20.
//
//

import UIKit

let TitleHeight:CGFloat = 56.0
let BottomPercent:CGFloat = 0.85

public enum SequenceStyle:Int {
    case normal
    case cover
}

class CardLayoutAttributes: UICollectionViewLayoutAttributes {
    var isExpand = false
  
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let attribute = super.copyWithZone(zone) as! CardLayoutAttributes
        attribute.isExpand = isExpand
        return attribute

    }
}

class CustomCardLayout: UICollectionViewLayout {
    
    private var insertPath = [NSIndexPath]()
    private var deletePath = [NSIndexPath]()
    private var attributeList:[CardLayoutAttributes]!
    private var bottomShowSet = [Int]()
    private var _selectIdx = -1
    var showStyle:SequenceStyle = .normal {
        didSet {
            self.collectionView?.performBatchUpdates({
                self.invalidateLayout()
            }, completion: nil)
        }
    }
    
    var selectIdx:Int {
        set {
            if selectIdx >= 0 && newValue >= 0 {
                self.collectionView?.scrollEnabled = true
                _selectIdx = -1
            } else {
                if newValue >= 0 {
                    self.collectionView?.scrollEnabled = false
                }
                _selectIdx = newValue
            }
            self.collectionView?.performBatchUpdates({
                self.collectionView?.reloadData()
            }, completion: nil)
        } get {
            return _selectIdx
        }
    }
    
    var bottomShowCount = 6 {
        didSet {
            self.collectionView?.performBatchUpdates({
                self.collectionView?.reloadData()
            }, completion: nil)
        }
    }
    
    var isFullScreen = false {
        didSet {
            self.collectionView?.performBatchUpdates({
                self.collectionView?.reloadData()
            }, completion: nil)
        }
    }
    
    lazy var cellSize:CGSize = {
        let w = self.collectionView!.bounds.width
        let h = self.collectionView!.bounds.height * BottomPercent
        let size = CGSize.init(width: w, height: h)
        return size
    }()

    override func collectionViewContentSize() -> CGSize {
        let count = self.collectionView!.numberOfItemsInSection(0)
        let contentHeight = TitleHeight*CGFloat(count-1) + cellSize.height
        return CGSize.init(width: cellSize.width, height: contentHeight )

    }
    
    override func prepareLayout() {
        super.prepareLayout()
        attributeList = self.generateAttributeList()

    }
    private func generateAttributeList() -> [CardLayoutAttributes] {

        var arr = [CardLayoutAttributes]()
        let count = self.collectionView!.numberOfItemsInSection(0)
        var bottomIdx:CGFloat = 0
        bottomShowSet = self.bottomIdxArr()
 
        var realIdx = 0
        for i in 0..<count {
            let indexPath = NSIndexPath.init(forRow: i, inSection: 0)
            let attr = CardLayoutAttributes.init(forCellWithIndexPath: indexPath)
            attr.zIndex = i
            
            if selectIdx < 0 {
                self.setNoSelect(attr, realIdx: &realIdx)
            } else if selectIdx == i{
                self.setSelect(attr)
            } else {
                self.setBottom(attr, bottomIdx: &bottomIdx)
            }
            arr.append(attr)
        }
        return arr
    }
    
    private func setNoSelect(attribute:CardLayoutAttributes, inout realIdx:Int) {
        
        let shitIdx = Int(self.collectionView!.contentOffset.y/TitleHeight)
        let index = attribute.indexPath.row
        var currentFrame = CGRect.zero
        currentFrame = CGRect(x: self.collectionView!.frame.origin.x, y: TitleHeight * CGFloat(index), width: cellSize.width, height: cellSize.height)

        switch showStyle {
            case .cover:
                if index <= shitIdx && (index >= shitIdx-2) || index == 0{
                    attribute.frame = CGRect(x: currentFrame.origin.x, y: self.collectionView!.contentOffset.y, width: cellSize.width, height: cellSize.height)
                } else {
                    attribute.frame = currentFrame
                }
            case .normal:
                attribute.frame = currentFrame
        }
    }
    
    private func setSelect(attribute:CardLayoutAttributes) {
        attribute.isExpand = true
        // 0.01 prevent no reload
        attribute.frame = CGRect.init(x: self.collectionView!.frame.origin.x, y: self.collectionView!.contentOffset.y+0.01 , width: cellSize.width, height: cellSize.height)
    }
    
    private func setBottom(attribute:CardLayoutAttributes, inout bottomIdx:CGFloat) {
        let index = attribute.indexPath.row
        let currentFrame = CGRect(x: self.collectionView!.frame.origin.x, y: TitleHeight * CGFloat(index), width: cellSize.width, height: cellSize.height)
        let baseHeight = self.collectionView!.contentOffset.y + collectionView!.bounds.height * 0.90
        let bottomH = cellSize.height  * 0.1
        let margin:CGFloat = bottomH/CGFloat(bottomShowCount)
        attribute.isExpand = false
        let maxY = self.collectionView!.contentOffset.y + self.collectionView!.frame.height
        let contentFrame = CGRect(x: 0, y: self.collectionView!.contentOffset.y, width: self.collectionView!.frame.width, height: maxY)
        
        if bottomShowSet.contains(index) {
            let yPos = (self.isFullScreen) ? (self.collectionView!.contentOffset.y + collectionView!.bounds.height) : bottomIdx * margin + baseHeight
            attribute.frame = CGRect.init(x: 0, y: yPos, width: cellSize.width, height: cellSize.height)
            bottomIdx += 1
        } else if contentFrame.intersects(currentFrame)  {
            attribute.frame = CGRect.init(x: 0, y: maxY, width: cellSize.width, height: cellSize.height)
        }else {
            attribute.frame = CGRect(x: 0, y: TitleHeight * CGFloat(index), width: cellSize.width, height: cellSize.height)
        }
    }
    
    private func bottomIdxArr() -> [Int] {
        
        if selectIdx == -1 { return [Int]() }
        
        let count = self.collectionView!.numberOfItemsInSection(0) - 1

        let half = Int(bottomShowCount/2)
        var min = selectIdx - half
        var max = selectIdx + half
        
        if selectIdx - half < 0 {
            min = 0
            max = selectIdx + half + abs(selectIdx-half)
        } else if selectIdx + half > count {
            min = count - 2*half
            max = count
        }
        
        return Array(min...max).filter({ (value) -> Bool in
            return value > 0 && value != selectIdx
        })
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return attributeList[indexPath.row]

    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let arr =  attributeList.filter { (layout) -> Bool in
            return layout.frame.intersects(rect)
        }
        return  arr
    }

    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    
        let at = (itemIndexPath.row > attributeList.count-1) ?
            super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath) : attributeList[itemIndexPath.row]
        if self.deletePath.contains(itemIndexPath) {
            let randomLoc = (itemIndexPath.row%2 == 0) ? 1 : -1
            let x = self.collectionView!.frame.width * CGFloat(randomLoc)
            
            at?.transform = CGAffineTransformMakeTranslation(x, 0)
        }
        return at
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        let at = (itemIndexPath.row > attributeList.count-1) ? super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath) :attributeList[itemIndexPath.row]
        if self.insertPath.contains(itemIndexPath) {
            let randomLoc = (itemIndexPath.row%2 == 0) ? 1 : -1
            let x = self.collectionView!.frame.width * CGFloat(randomLoc)
            
            at?.transform = CGAffineTransformMakeTranslation(x,0)
            
        }
        return at
    }
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
                return true
    }
    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        super.prepareForCollectionViewUpdates(updateItems)
        deletePath.removeAll()
        insertPath.removeAll()
        for update in updateItems {
            if update.updateAction == .Delete {
                
                let path = (update.indexPathBeforeUpdate != nil) ? update.indexPathBeforeUpdate : update.indexPathAfterUpdate
                if let p = path {
                    deletePath.append(p)
                }
            } else if let path = update.indexPathAfterUpdate where update.updateAction == .Insert {
                insertPath.append(path)
            }
        }
    }
}
