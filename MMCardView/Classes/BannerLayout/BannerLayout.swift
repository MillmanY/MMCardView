
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
    private var _realFrame = CGRect.zero
    var realFrame: CGRect {
        set {
            self._realFrame = newValue
            self.frame = newValue
        } get {
            return self._realFrame
        }
    }
    override func copy(with zone: NSZone? = nil) -> Any {
        let attribute = super.copy(with: zone) as! BannerLayoutAttributes
        return attribute
    }
}

public class BannerLayout: UICollectionViewLayout {
    public var itemSpace:CGFloat = 0.0
    
    public var angle: CGFloat = 0.0
    fileprivate var radius: CGFloat{
        get {
            return angle*CGFloat.pi/180
        }
    }
    fileprivate var angleItemWidth: CGFloat {
        get {
            return itemSize.width*cos(radius)
        }
    }
    
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
                    let isAnimate = !(!self.isInfinite && newValue == 0)
                    
                    let x = self.collectionView!.contentOffset.x + attr.realFrame.midX - centerX
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
            let twoDistance =  itemSize.width/2+angleItemWidth/2+itemSpace

            let current = Int(floor( start / (twoDistance))) > total-1 ? total-1 : Int(floor( start / (twoDistance)))
            let end = Int(floor((start + width) / twoDistance))
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
        let first = one.width-(width-angleItemWidth)/2
        let another = one.width-(width-angleItemWidth)+itemSpace
        return (CGSize(width: first, height: height) , CGSize(width: another, height: height))
    }
    
    fileprivate func totalContentSize(isInfinite: Bool) -> CGSize {
        switch style {
        case .normal:
            let twoDistance =  itemSize.width/2+angleItemWidth/2+itemSpace

            let width = (isInfinite) ? CGFloat.greatestFiniteMagnitude : CGFloat(self.collectionView!.calculate.totalCount-1) * (twoDistance) + self.collectionView!.frame.width
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
        let (first ,another) = self.cycleSize()
        
        let centerX = self.collectionView!.contentOffset.x + (self.collectionView!.frame.width/2)
        
        let lastIdx = self.collectionView!.calculate.totalCount - 1
        var setIdx = [Int]()
        var centerIdx = 0
        var preDistance = CGFloat.greatestFiniteMagnitude
        
        let twoDistance =  itemSize.width/2+angleItemWidth/2+itemSpace
        (range.start.cycle...range.end.cycle).forEach { (cycle) in
            let start = cycle == range.start.cycle ? range.start.index : 0
            let end  = cycle == range.end.cycle ? range.end.index : lastIdx
            var x:CGFloat = 0
            (start...end).forEach({ (idx) in
                
                let location = twoDistance*CGFloat(idx)
                if cycle == 0 {
                    if idx == 0{
                        x = (width-itemSize.width)/2
                    } else {
                        x = (width-itemSize.width)/2 + location
                    }
//                    x = (idx == 0) ? (width-itemSize.width)/2 : (width-itemSize.width)/2 + location
                } else {
                    let cycleF = first.width + CGFloat(cycle-1) * another.width + itemSpace
                    x = (idx == 0) ? cycleF : cycleF + location
                }
                let f = CGRect(x: x, y: (height - itemSize.height)/2, width: itemSize.width, height: itemSize.height)
                let mid = CGPoint(x: f.midX, y: f.midY)
                let distance = mid.distance(point: CGPoint(x: centerX, y: self.collectionView!.contentOffset.y))
                if preDistance > distance {
                    preDistance = distance
                    centerIdx = idx
                }
                attributeList[idx].realFrame = f
                setIdx.append(idx)
            })
        }
        let midX = attributeList[_currentIdx].frame.midX
        var percent = abs(centerX-midX)/twoDistance
        if percent >= 1 {
            percent = 0.0
            self._currentIdx = centerIdx
        }
    
        let centerLoc = setIdx.index(of: _currentIdx) ?? 0
        var transform = CATransform3DIdentity
        transform.m34  = -1 / 500
        setIdx.enumerated().forEach {
            switch $0.offset {
            case centerLoc-1:
                let fix = centerX < midX ? radius*(1-percent) : radius
                attributeList[$0.element].transform3D = CATransform3DRotate(transform, fix, 0, 1, 0)
            case centerLoc+1:
                let fix = centerX > midX ? -radius*(1-percent) : -radius
                attributeList[$0.element].transform3D = CATransform3DRotate(transform, fix, 0, 1, 0)
            case centerLoc:
                if centerX == midX {
                    attributeList[$0.element].transform3D = CATransform3DIdentity
                } else {
                    let fix = centerX > midX ? radius*(percent) : -radius*(percent)
                    attributeList[$0.element].transform3D = CATransform3DRotate(transform, fix, 0, 1, 0)
                }
            default:
                let r = $0.offset > centerLoc ? -radius :radius
                attributeList[$0.element].transform3D = CATransform3DRotate(transform, r, 0, 1, 0)
            }
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
            let lastIdx = self.collectionView!.calculate.totalCount - 1
            let centerX = self.collectionView!.contentOffset.x + (self.collectionView!.frame.width/2)
            
            if velocity.x != 0 {
                var idx = _currentIdx
                
                if velocity.x > 0 {
                    if !self.isInfinite {
                        idx = (_currentIdx+1 > lastIdx) ? lastIdx : _currentIdx+1
                    } else {
                        idx = (_currentIdx+1 > lastIdx) ? (currentIdx+1)%lastIdx : _currentIdx+1
                    }
                } else {
                    if !self.isInfinite {
                        idx = (_currentIdx-1 < 0) ? 0 : currentIdx-1
                    } else {
                        idx = (_currentIdx-1 < 0) ? lastIdx : currentIdx-1
                    }
                }
                if let attr = self.attributeList[safe: idx] {
                    self._currentIdx = idx
                    fix.x = self.collectionView!.contentOffset.x + attr.realFrame.midX - centerX
                }
            } else {
                if let attr = self.findCenterAttribute()  {
                    self._currentIdx = attributeList.index(of: attr)!
                    fix.x = self.collectionView!.contentOffset.x + attr.realFrame.midX - centerX
                }
            }
        }
        return fix
    }
    
    fileprivate func findCenterAttribute() -> BannerLayoutAttributes? {
        let centerX = self.collectionView!.contentOffset.x + (self.collectionView!.frame.width/2)
        var attribute: BannerLayoutAttributes?
        var preDistance = CGFloat.greatestFiniteMagnitude
        attributeList.enumerated().forEach({
            let mid = CGPoint(x: $0.element.realFrame.midX, y: $0.element.realFrame.midY)
            let distance = mid.distance(point: CGPoint(x: centerX, y: self.collectionView!.contentOffset.y))
            if preDistance > distance {
                preDistance = distance
                attribute = $0.element
            }
        })
        return attribute
    }
}
