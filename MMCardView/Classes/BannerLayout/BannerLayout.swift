
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

class BannerLayoutAttributes: UICollectionViewLayoutAttributes {
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let attribute = super.copy(with: zone) as! BannerLayoutAttributes
        return attribute
    }
}

public class BannerLayout: UICollectionViewLayout {
    fileprivate var _currentIdx = 0
    public var currentIdx:Int {
        set {
            switch self.style {
            case .normal:
                let needAnimate = !(newValue == 0 && currentIdx != 0)
                let x = (self.collectionView!.frame.width) * CGFloat(newValue)
                self.collectionView!.setContentOffset(CGPoint(x: x, y: 0), animated: needAnimate)
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
    
    fileprivate func totalContentSize(isInfinite: Bool) -> CGSize {
        switch style {
        case .normal:
            let width = (isInfinite) ? CGFloat.greatestFiniteMagnitude : CGFloat(self.collectionView!.calculate.totalCount) * self.collectionView!.frame.width
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
        self.currentIdx = (will < self.collectionView!.calculate.totalCount - 1) ? will : 0
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
        let width = self.collectionView!.frame.width
        let height = self.collectionView!.frame.height
        let one = self.totalContentSize(isInfinite: false)
        let cycle = (self.collectionView!.contentOffset.x) / one.width
        let needShowNext = fmodf(Float(cycle),1.0) >= 0.80
        let fl = floor(cycle)
        attributeList.enumerated().forEach {
            let fix = (needShowNext && $0.offset == 0) ? fl+1 : fl
            let x = CGFloat($0.offset) * width + (fix * one.width)
            $0.element.frame = CGRect(x: x, y: 0, width: width, height: height)
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
        
            let page = round(proposedContentOffset.x/self.collectionView!.frame.width)
            if velocity.x == 0 {
                _currentIdx = Int(page)
            } else {
                let append = velocity.x > 0 ? 1 : -1
                _currentIdx = Int(page) + append
            }
            fix.x = (self.collectionView!.frame.width) * CGFloat(self.currentIdx)
        }
        
        return fix
    }
}
