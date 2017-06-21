//
//  MMCardCollectionView.swift
//  Pods
//
//  Created by Millman YANG on 2017/6/21.
//
//

import UIKit
public enum LayoutStyle {
    case card
}

public class MMCollectionView: UICollectionView {

    fileprivate lazy var _proxyDelegate: DelegateProxy = {
        return DelegateProxy(parentObject: self)
    }()
    var layoutStyle: LayoutStyle = .card {
        didSet {
            switch layoutStyle {
            case .card:
                self.collectionViewLayout = CustomCardLayout()
            }
        }
    }
    override public var delegate: UICollectionViewDelegate? {
        get {
            return super.delegate
        } set {
            self._proxyDelegate.setForward(newValue)
            super.delegate = _proxyDelegate
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setup()
    }
    
    func setup() {
        self.layoutStyle = .card
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
//        switch self.collectionViewLayout {
//        case let l as CustomCardLayout:
//            l.updateCellSize()
//        default:
//            break
//        }
//        self.reloadData()
    }
    
    public func expandBottomCount(count:Int) {
        if let layout = self.collectionViewLayout as? CustomCardLayout {
            layout.bottomShowCount = count
        }
    }
    
    public func setCardTitleHeight(heihgt:CGFloat) {
        DispatchQueue.main.async {
            if let layout = self.collectionViewLayout as? CustomCardLayout {
                layout.titleHeight = heihgt
            }
        }
    }
    
    public func setCardHeight(height:CGFloat) {
        DispatchQueue.main.async {
            if let layout = self.collectionViewLayout as? CustomCardLayout {
                layout.cellSize = CGSize.init(width: layout.cellSize.width, height: height)
                layout.invalidateLayout()
            }
        }
    }
    
    public func showStyle(style:SequenceStyle) {
        print(self.subviews)
//        self.reloadData()
        self.subviews.forEach { (vi) in
            vi.isHidden = false
        }
//        DispatchQueue.main.async {
//            if let custom = self.collectionViewLayout as? CustomCardLayout {
//                custom.showStyle = style
//            }
//        }
    }
}

extension MMCollectionView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let c = cell as? CardCell {
            c.collectionV = collectionView
            c.reloadBlock = {
                if let custom = collectionView.collectionViewLayout as? CustomCardLayout {
                    custom.selectPath = nil
                }
            }
            c.isHidden = false
        }
//        _proxyDelegate._forwardToDelegate
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.collectionViewLayout {
        case let l as CustomCardLayout:
            l.selectPath = indexPath
        default:
            break
        }
        _proxyDelegate._forwardToDelegate.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
}
