
//
//  BannerLayout.swift
//  Pods
//
//  Created by Millman YANG on 2017/7/4.
//
//

import UIKit
public enum BannerStyle {
    case normal
}

class InfiniteLayoutRange {
    let start:(cycle: Int,index: Int)
    let end:(cycle:Int, index: Int)
    
    init(start: (cycle: Int,index: Int), end: (cycle:Int, index: Int)) {
        self.start = start
        self.end = end
    }
}

class BannerLayoutAttributes: UICollectionViewLayoutAttributes {
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let attribute = super.copy(with: zone) as! BannerLayoutAttributes
        return attribute
    }
}

public class BannerLayout: UICollectionViewLayout {
    public var itemSpace:CGFloat = 0.0
    
    fileprivate var _itemSize:CGSize?
    public var itemSize: CGSize{
        set {
            self._itemSize = newValue
        } get {
            return _itemSize ?? self.collectionView!.frame.size
        }
    }
    
    fileprivate var _currentIdx = 0
    public var currentIdx:Int {
        set {
            switch self.style {
            case .normal:
                let centerX = self.collectionView!.contentOffset.x + (self.collectionView!.frame.width/2)

                if let attr = self.attributeList[safe: newValue] {
                    let x = self.collectionView!.contentOffset.x + attr.frame.midX - centerX
                    self.collectionView!.setContentOffset(CGPoint(x: x, y: 0), animated: true)
                }
            }
            self._currentIdx = newValue

        } get {
            return _currentIdx
        }
    }
    
    public var isInfinite:Bool = false {
        didSet {
            self.invalidateLayout()
        }
    }
    
    fileprivate var timer: Timer?
    public var autoPlayBanner: Bool = false {
        didSet {
            self.setPlayTimer()
        }
    }
    
    public var playDuration: TimeInterval = 3.0 {
        didSet {
            self.setPlayTimer()
        }
    }
    
    public var style: BannerStyle = .normal {
        didSet {

        }
    }

    fileprivate var attributeList = [BannerLayoutAttributes]()
    override public var collectionViewContentSize: CGSize {
        get {
            return self.totalContentSize(isInfinite: self.isInfinite)
        }
    }
    fileprivate var indexRange: InfiniteLayoutRange {
        get {
            let total = self.collectionView!.calculate.totalCount
            let width = self.collectionView!.frame.width
            let one = self.totalContentSize(isInfinite: false)
            let first = one.width-(width-itemSize.width)/2
            let another = one.width-(width-itemSize.width)+itemSpace
            var cycle = 0
            var start:CGFloat = self.collectionView!.contentOffset.x
            if self.collectionView!.contentOffset.x > first {
                cycle = 1 + Int(floor((self.collectionView!.contentOffset.x-first)/another))
                start = start - (first + CGFloat(cycle-1) * another)
            }
            
            let current = Int(floor( start / (itemSize.width + itemSpace))) > total-1 ? total-1 : Int(floor( start / (itemSize.width + itemSpace)))
            let end = Int(floor((start + width) / itemSize.width))
            var endCycle = end / total + cycle
            var e = end%total

            if !self.isInfinite && endCycle > 0 {
                endCycle = 0
                e = total - 1
            }
            return InfiniteLayoutRange(start: (cycle, current), end: (endCycle, e))
        }
    }
    
    fileprivate func totalContentSize(isInfinite: Bool) -> CGSize {
        switch style {
        case .normal:
            let width = (isInfinite) ? CGFloat.greatestFiniteMagnitude : CGFloat(self.collectionView!.calculate.totalCount-1) * (itemSize.width + itemSpace) + self.collectionView!.frame.width
            let height = self.collectionView!.frame.height
            return CGSize(width: width, height: height)
        }
    }
    
    fileprivate func setPlayTimer() {
        timer?.invalidate()
        if !autoPlayBanner {
            timer = nil
        } else {
            timer = Timer.scheduledTimer(timeInterval: playDuration, target: self, selector: #selector(BannerLayout.autoScroll), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .commonModes)
        }
    }
    
    @objc fileprivate func autoScroll() {
        if self.collectionView!.isDragging {
            return
        }
        let will = self.currentIdx + 1
        self.currentIdx = (will < self.collectionView!.calculate.totalCount) ? will : 0
    }
    
    override public func prepare() {
        super.prepare()
        self.collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
        if self.collectionView!.calculate.isNeedUpdate() {
            attributeList.removeAll()
            attributeList = self.generateAttributeList()
        }
        self.setAttributeFrame()
    }
    
    fileprivate func setAttributeFrame() {
        if self.collectionView!.contentOffset.x < 0 {
            return
        }
        let width = self.collectionView!.frame.width
        let height = self.collectionView!.frame.height
        
        let range =  self.indexRange
        let one = self.totalContentSize(isInfinite: false)
        let first = one.width-(width-itemSize.width)/2
        let another = one.width-(width-itemSize.width)+itemSpace
        (range.start.cycle...range.end.cycle).forEach { (cycle) in
            let start = cycle == range.start.cycle ? range.start.index : 0
            let end  = cycle == range.end.cycle ? range.end.index : self.collectionView!.calculate.totalCount - 1
            var x:CGFloat = 0
            (start...end).forEach({ (idx) in
                let location = (itemSize.width+itemSpace)*CGFloat(idx)
                if cycle == 0 {
                    x = (idx == 0) ? (width-itemSize.width)/2 : location + (width-itemSize.width)/2
                } else {
                    let cycleF = first + CGFloat(cycle-1) * another + itemSpace
                    x = (idx == 0) ? cycleF : cycleF + location
                }
                attributeList[idx].frame = CGRect(x: x, y: (height - itemSize.height)/2, width: itemSize.width, height: itemSize.height)
            })
        }
    }
    
    fileprivate func generateAttributeList() -> [BannerLayoutAttributes] {
        return (0..<self.collectionView!.numberOfSections).flatMap { (section) -> [BannerLayoutAttributes] in
            (0..<self.collectionView!.numberOfItems(inSection: section)).map({
                return BannerLayoutAttributes(forCellWith: IndexPath(row: $0, section: section))
            })
        }
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let first = attributeList.first(where: { $0.indexPath == indexPath }) else {
            let attr = BannerLayoutAttributes(forCellWith: indexPath)
            return attr
        }
        return first
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let arr = attributeList.filter { $0.frame.intersects(rect) }
        return arr
    }
    
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var fix = proposedContentOffset
        switch self.style {
        case .normal:
            let centerX = self.collectionView!.contentOffset.x + (self.collectionView!.frame.width/2)
            var attribute: BannerLayoutAttributes?
            var preDistance = CGFloat.greatestFiniteMagnitude
            
            if velocity.x != 0 {
                let idx = velocity.x > 0 ? _currentIdx+1 : _currentIdx-1
                if let attr = self.attributeList[safe: idx] {
                    fix.x = self.collectionView!.contentOffset.x + attr.frame.midX - centerX
                    self._currentIdx = idx
                }
            } else {
                var idx = 0
                attributeList.enumerated().forEach({
                    let mid = CGPoint(x: $0.element.frame.midX, y: $0.element.frame.midY)
                    let distance = mid.distance(point: CGPoint(x: centerX, y: self.collectionView!.contentOffset.y))
                    if preDistance > distance {
                        preDistance = distance
                        attribute = $0.element
                        idx = $0.offset
                    }
                })
                if let attr = attribute {
                    self._currentIdx = idx
                    fix.x = self.collectionView!.contentOffset.x + attr.frame.midX - centerX
                }
            }
       }
        return fix
    }
}
