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
    fileprivate var attributeList = [CardLayoutAttributes]()
    
    var showStyle:SequenceStyle = .normal {
        didSet {
            self.collectionView?.performBatchUpdates({
                self.invalidateLayout()
            }, completion: nil)
        }
    }
    fileprivate var _selectPath: IndexPath?
    public var selectPath: IndexPath? {
        set {
            if _selectPath == newValue {
                self.collectionView!.isScrollEnabled = true
                _selectPath = nil
            } else {
                self.collectionView!.isScrollEnabled = false
                _selectPath = newValue
            }
            self.collectionView?.performBatchUpdates({
                self.invalidateLayout()
            }, completion: nil)
        } get {
            return _selectPath
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
            let sections = self.collectionView!.numberOfSections
            let total = (0..<sections).reduce(0) { (total, current) -> Int in
                return total + self.collectionView!.numberOfItems(inSection: current)
            }
            let contentHeight = titleHeight*CGFloat(total-1) + cellSize.height
            return CGSize(width: cellSize.width, height: contentHeight )
        }
    }
    
    func updateCellSize() {
        self.cellSize.width  = self.collectionView!.frame.width
        self.cellSize.height = self.collectionView!.bounds.height * BottomPercent
    }
    
    override func prepare() {
        super.prepare()

        if let select = self.selectPath {
            var bottomIdx:CGFloat = 0
            self.attributeList.forEach({
                if $0.indexPath == select {
                    self.setSelect(attribute: $0)
                } else {
                    self.setBottom(attribute: $0, bottomIdx: &bottomIdx)
                }
            })
        } else {
            self.attributeList.removeAll()
            self.attributeList += self.generateAttributeList()
        }
    }
    
    fileprivate func generateAttributeList() -> [CardLayoutAttributes] {

        var arr = [CardLayoutAttributes]()
        let offsetY = self.collectionView!.contentOffset.y > 0 ? self.collectionView!.contentOffset.y : 0
        let startIdx = abs(Int(offsetY/titleHeight))
        let sections = self.collectionView!.numberOfSections
        var itemsIdx = 0
        
        for sec in 0..<sections {
            let count = self.collectionView!.numberOfItems(inSection: sec)
            if itemsIdx + count-1 < startIdx {
                itemsIdx = count-1
                continue
            }
            for item in 0..<count {
                if itemsIdx >= startIdx {
                    let indexPath = IndexPath(item: item, section: sec)
                    let attr = CardLayoutAttributes(forCellWith: indexPath)
                    attr.zIndex = itemsIdx
                    self.setNoSelect(attribute: attr, realIdx: itemsIdx)
                    let needAppend = CGFloat(arr.count-1) * titleHeight < collectionView!.frame.height
                    if !needAppend {
                        return arr
                    }
                    attr.isHidden = false
                    arr.append(attr)
                }
                itemsIdx += 1
            }
        }
        return arr
    }
    
    fileprivate func setNoSelect(attribute:CardLayoutAttributes, realIdx: Int) {
        
        let shitIdx = Int(self.collectionView!.contentOffset.y/titleHeight)
        let index = realIdx
        var currentFrame = CGRect.zero
        currentFrame = CGRect(x: self.collectionView!.frame.origin.x, y: titleHeight * CGFloat(index), width: cellSize.width, height: cellSize.height)
        switch showStyle {
            case .cover:
                if index <= shitIdx && (index >= shitIdx-2) || index == 0{
                    attribute.frame = CGRect(x: currentFrame.origin.x, y: self.collectionView!.contentOffset.y, width: cellSize.width, height: cellSize.height)
                } else if index <= shitIdx-2 && currentFrame.maxY > self.collectionView!.contentOffset.y{
                    currentFrame.origin.y -= (currentFrame.maxY - self.collectionView!.contentOffset.y )
                    attribute.frame = currentFrame
                }else {
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
        let baseHeight = self.collectionView!.contentOffset.y + collectionView!.bounds.height * 0.90
        let bottomH = cellSize.height  * 0.1
        let margin:CGFloat = bottomH/CGFloat(bottomShowCount)
        attribute.isExpand = false
        let yPos = (self.isFullScreen) ? (self.collectionView!.contentOffset.y + collectionView!.bounds.height) : bottomIdx * margin + baseHeight
        attribute.frame = CGRect.init(x: 0, y: yPos, width: cellSize.width, height: cellSize.height)
        bottomIdx += 1
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributeList.first(where: { $0.indexPath == indexPath })
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
