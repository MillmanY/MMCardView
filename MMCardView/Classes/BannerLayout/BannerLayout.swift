
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

struct InfiniteLayoutRange {
    var start:(cycle: Int,index: Int) = (0,0)
    var end:(cycle:Int, index: Int) = (0,0)
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
    public var angle: CGFloat = 0.0
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
                    let isAnimate = !(!self.isInfinite && newValue == 0)
                    
                    let x = self.collectionView!.contentOffset.x + attr.frame.midX - centerX
                    self.collectionView!.setContentOffset(CGPoint(x: x, y: 0), animated: isAnimate)
                }
            }
            self._currentIdx = newValue

        } get {
            return _currentIdx
        }
    }
    
    public var isInfinite:Bool = false {
        didSet {
            if isInfinite {
                let (first, another) = self.cycleSize()
                let start = first.width+another.width*100000
                let infiniteStart =  start - (self.collectionView!.frame.width/2) + itemSpace+itemSize.width/2
                self.collectionView!.setContentOffset(CGPoint(x: infiniteStart, y: 0), animated: false)
                self.collectionView!.showsHorizontalScrollIndicator = false
            }
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
    
    fileprivate var _indexRange = InfiniteLayoutRange()
    fileprivate var indexRange: InfiniteLayoutRange {
        get {
            let total = self.collectionView!.calculate.totalCount
            let width = self.collectionView!.frame.width
            let (first ,another) = self.cycleSize()
            var cycle = 0
            var start:CGFloat = self.collectionView!.contentOffset.x
            if self.collectionView!.contentOffset.x > first.width {
                cycle = 1 + Int(floor((self.collectionView!.contentOffset.x-first.width)/another.width))
                start = start - (first.width + CGFloat(cycle-1) * another.width)
            }
            
            let current = Int(floor( start / (itemSize.width + itemSpace))) > total-1 ? total-1 : Int(floor( start / (itemSize.width + itemSpace)))
            let end = Int(floor((start + width) / itemSize.width))
            var endCycle = end / total + cycle
            var e = end%total

            if !self.isInfinite && endCycle > 0 {
                endCycle = 0
                e = total - 1
            }
            
            _indexRange.start = (cycle, current)
            _indexRange.end = (endCycle, e)
            return _indexRange
        }
    }
    
    fileprivate func cycleSize() -> (first: CGSize, another: CGSize) {
        let width = self.collectionView!.frame.width
        let height = self.collectionView!.frame.height
        let one = self.totalContentSize(isInfinite: false)
        let first = one.width-(width-itemSize.width)/2
        let another = one.width-(width-itemSize.width)+itemSpace
        return (CGSize(width: first, height: height) , CGSize(width: another, height: height))
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
            let reset = self.isInfinite
            self.isInfinite = reset
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
        
        let radius = angle*CGFloat.pi/180
//        let centerX = self.collectionView!.contentOffset.x + (self.collectionView!.frame.width/2)
        
        let lastIdx = self.collectionView!.calculate.totalCount - 1
//        var centerIdx = 0
//        var attribute: BannerLayoutAttributes?
//        var preDistance = CGFloat.greatestFiniteMagnitude
        (range.start.cycle...range.end.cycle).forEach { (cycle) in
            let start = cycle == range.start.cycle ? range.start.index : 0
            let end  = cycle == range.end.cycle ? range.end.index : lastIdx
            var x:CGFloat = 0
            (start...end).forEach({ (idx) in
                
                let location = (itemSize.width+itemSpace)*CGFloat(idx)*cos(radius)
                if cycle == 0 {
                    x = (idx == 0) ? (width-itemSize.width)/2 : location + (width-itemSize.width)/2
                } else {
                    let cycleF = first + CGFloat(cycle-1) * another + itemSpace
                    x = (idx == 0) ? cycleF : cycleF + location
                }
                let f = CGRect(x: x, y: (height - itemSize.height)/2, width: itemSize.width, height: itemSize.height)
                attributeList[idx].frame = f
//                let mid = CGPoint(x: f.midX, y: f.midY)
//                let distance = mid.distance(point: CGPoint(x: centerX, y: self.collectionView!.contentOffset.y))
//                if preDistance > distance {
//                    preDistance = distance
//                    attribute = $0.element
//                }

                
            })
        }
//        var transform = CATransform3DIdentity
//        transform.m34  = -1 / 500
//
//        let midX = attributeList[currentIdx].frame.midX
//        let nextIdx = (currentIdx+1>lastIdx) ? (currentIdx+1)%lastIdx : currentIdx+1
//        let preIdx = (currentIdx-1<0) ? lastIdx : currentIdx-1
//
//        if centerX == midX {
//            attributeList[currentIdx].transform3D = CATransform3DIdentity
//            attributeList[nextIdx].transform3D = CATransform3DRotate(transform, -radius, 0, 1, 0)
//            attributeList[preIdx].transform3D = CATransform3DRotate(transform, radius, 0, 1, 0)
//        } else if centerX > midX {
//            let nextMid = attributeList[nextIdx].frame.midX
//            let percent = (centerX-midX)/(nextMid-midX)
//            attributeList[currentIdx].transform3D = CATransform3DRotate(transform, radius*(percent), 0, 1, 0)
//            attributeList[nextIdx].transform3D = CATransform3DRotate(transform, -radius*(1-percent), 0, 1, 0)
//            attributeList[preIdx].transform3D = CATransform3DRotate(transform, radius, 0, 1, 0)
//        } else {
//            let preMid = attributeList[preIdx].frame.midX
//            let percent = (midX-centerX)/(midX-preMid)
//            attributeList[currentIdx].transform3D = CATransform3DRotate(transform, -radius*(percent), 0, 1, 0)
//            attributeList[nextIdx].transform3D = CATransform3DRotate(transform, -radius, 0, 1, 0)
//            attributeList[preIdx].transform3D = CATransform3DRotate(transform, radius*(1-percent), 0, 1, 0)
//        }
        
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
            let lastIdx = self.collectionView!.calculate.totalCount - 1
            let centerX = self.collectionView!.contentOffset.x + (self.collectionView!.frame.width/2)
            
            if velocity.x != 0 {
                var idx = _currentIdx
                
                if velocity.x > 0 {
                    idx = (_currentIdx+1 > lastIdx) ? (currentIdx+1)%lastIdx : _currentIdx+1
                } else {
                    idx = (_currentIdx-1 < 0) ? lastIdx : currentIdx-1
                }
                
                if let attr = self.attributeList[safe: idx] {
                    fix.x = self.collectionView!.contentOffset.x + attr.frame.midX - centerX
                    self._currentIdx = idx
                }
            } else {
                if let attr = self.findCenterAttribute() as? BannerLayoutAttributes {
                    self._currentIdx = self.attributeList.index(of: attr)!
                    fix.x = self.collectionView!.contentOffset.x + attr.frame.midX - centerX
                }
            }
        }
        
        return fix
    }
    
    fileprivate func findCenterAttribute() -> UICollectionViewLayoutAttributes? {
        let centerX = self.collectionView!.contentOffset.x + (self.collectionView!.frame.width/2)
        var attribute: BannerLayoutAttributes?
        var preDistance = CGFloat.greatestFiniteMagnitude
        attributeList.enumerated().forEach({
            let mid = CGPoint(x: $0.element.frame.midX, y: $0.element.frame.midY)
            let distance = mid.distance(point: CGPoint(x: centerX, y: self.collectionView!.contentOffset.y))
            if preDistance > distance {
                preDistance = distance
                attribute = $0.element
            }
        })
        return attribute
    }
}
