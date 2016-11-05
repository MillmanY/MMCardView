//
//  CustomCardLayout.swift
//  Pods
//
//  Created by MILLMAN on 2016/9/20.
//
//

import UIKit

let BottomPercent:CGFloat = 0.85

public enum SequenceStyle:Int {
    case normal
    case cover
}

class CardLayoutAttributes: UICollectionViewLayoutAttributes {
    var isExpand = false
    override func copy(with zone: NSZone? = nil) -> Any {
        let attribute = super.copy(with: zone) as! CardLayoutAttributes
        attribute.isExpand = isExpand
        return attribute
    }
}

class CustomCardLayout: UICollectionViewLayout {
    fileprivate var insertPath = [IndexPath]()
    fileprivate var deletePath = [IndexPath]()
    fileprivate var attributeList:[CardLayoutAttributes]!
    fileprivate var bottomShowSet = [Int]()
    fileprivate var _selectIdx = -1
    var showStyle:SequenceStyle = .normal {
        didSet {
            self.collectionView?.performBatchUpdates({
                self.invalidateLayout()
            }, completion: nil)
        }
    }
    
    var selectIdx:Int {
        set {
            
            if self.collectionView?.numberOfItems(inSection: 0) == 1 {
                self.collectionView?.isScrollEnabled = false
                _selectIdx = 0
            } else if selectIdx >= 0 && newValue >= 0 {
                self.collectionView?.isScrollEnabled = true
                _selectIdx = -1
            } else {
                if newValue >= 0 {
                    self.collectionView?.isScrollEnabled = false
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
    
    var titleHeight:CGFloat = 56.0 {
        didSet {
            self.collectionView?.performBatchUpdates({ 
                self.invalidateLayout()
            }, completion: nil)
        }
    }
    
    lazy var cellSize:CGSize = {
        let w = self.collectionView!.bounds.width
        let h = self.collectionView!.bounds.height * BottomPercent
        let size = CGSize.init(width: w, height: h)
        return size
    }()

    override var collectionViewContentSize: CGSize {
        set {}
        get {
            let count = self.collectionView!.numberOfItems(inSection: 0)
            let contentHeight = titleHeight*CGFloat(count-1) + cellSize.height
            return CGSize.init(width: cellSize.width, height: contentHeight )
        }
    }
    
    override func prepare() {
        super.prepare()
        self.attributeList = self.generateAttributeList()
    }
        
    fileprivate func generateAttributeList() -> [CardLayoutAttributes] {

        var arr = [CardLayoutAttributes]()
        let count = self.collectionView!.numberOfItems(inSection: 0)
        var bottomIdx:CGFloat = 0
        bottomShowSet = self.bottomIdxArr()
 
        var realIdx = 0
        for i in 0..<count {
            let indexPath = IndexPath(item: i, section: 0)
            let attr = CardLayoutAttributes.init(forCellWith: indexPath)
            attr.zIndex = i
            if selectIdx < 0 {
                self.setNoSelect(attribute: attr, realIdx: &realIdx)
            } else if selectIdx == i{
                self.setSelect(attribute: attr)
            } else {
                self.setBottom(attribute: attr, bottomIdx: &bottomIdx)
            }
            arr.append(attr)
        }
        return arr
    }
    
    fileprivate func setNoSelect(attribute:CardLayoutAttributes, realIdx:inout Int) {
        
        let shitIdx = Int(self.collectionView!.contentOffset.y/titleHeight)
        let index = attribute.indexPath.row
        var currentFrame = CGRect.zero
        currentFrame = CGRect(x: self.collectionView!.frame.origin.x, y: titleHeight * CGFloat(index), width: cellSize.width, height: cellSize.height)

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
    
    fileprivate func setSelect(attribute:CardLayoutAttributes) {
        attribute.isExpand = true
        // 0.01 prevent no reload
        attribute.frame = CGRect.init(x: self.collectionView!.frame.origin.x, y: self.collectionView!.contentOffset.y+0.01 , width: cellSize.width, height: cellSize.height)
    }
    
    fileprivate func setBottom(attribute:CardLayoutAttributes, bottomIdx:inout CGFloat) {
        let index = attribute.indexPath.row
        let currentFrame = CGRect(x: self.collectionView!.frame.origin.x, y: titleHeight * CGFloat(index), width: cellSize.width, height: cellSize.height)
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
            attribute.frame = CGRect(x: 0, y: titleHeight * CGFloat(index), width: cellSize.width, height: cellSize.height)
        }
    }
    
    fileprivate func bottomIdxArr() -> [Int] {
        
        if selectIdx == -1 { return [Int]() }
        
        let count = self.collectionView!.numberOfItems(inSection: 0) - 1

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
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributeList[indexPath.row]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let arr =  attributeList.filter { (layout) -> Bool in
            return layout.frame.intersects(rect)
        }
        
        return arr
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        

        let at = (itemIndexPath.row > attributeList.count-1) ? super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) :attributeList[itemIndexPath.row]
        if self.deletePath.contains(itemIndexPath) {
            let randomLoc = (itemIndexPath.row%2 == 0) ? 1 : -1
            let x = self.collectionView!.frame.width * CGFloat(randomLoc)
            
            at?.transform = CGAffineTransform.init(translationX: x, y: 0)
        }
        
        return at
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    
        let at = (itemIndexPath.row > attributeList.count-1) ? super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) :attributeList[itemIndexPath.row]
        if self.insertPath.contains(itemIndexPath) {
            let randomLoc = (itemIndexPath.row%2 == 0) ? 1 : -1
            let x = self.collectionView!.frame.width * CGFloat(randomLoc)
            
            at?.transform = CGAffineTransform.init(translationX: x, y: 0)
        }
        
        return at
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        deletePath.removeAll()
        insertPath.removeAll()
        for update in updateItems {
            if update.updateAction == .delete {
                
                let path = (update.indexPathBeforeUpdate != nil) ? update.indexPathBeforeUpdate : update.indexPathAfterUpdate
                if let p = path {
                    deletePath.append(p)
                }
            } else if let path = update.indexPathAfterUpdate, update.updateAction == .insert {
                insertPath.append(path)
            }
        }
    }

}
