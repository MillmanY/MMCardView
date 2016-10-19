//
//  CardCell.swift
//  Pods
//
//  Created by MILLMAN on 2016/9/20.
//
//

import UIKit

public protocol CardCellProtocol {
    static func cellIdentifier() -> String
}

open class CardCell:UICollectionViewCell{
    var collectionV:UICollectionView!
    var reloadBlock:(()->Void)?
    var customCardLayout:CardLayoutAttributes?
    var originTouchY:CGFloat = 0.0
    var pangesture:UIPanGestureRecognizer?
    func pan(rec:UIPanGestureRecognizer){
        if self.collectionV.numberOfItems(inSection: 0) == 1 {
            return
        }
        let point = rec.location(in: collectionV)
        let shiftY:CGFloat = (point.y - originTouchY  > 0) ? point.y - originTouchY : 0
        
        switch rec.state {
            case .began:
                originTouchY = point.y
            case .changed:
                self.transform = CGAffineTransform.init(translationX: 0, y: shiftY)

            default:
                let isNeedReload = (shiftY > self.contentView.frame.height/3) ? true : false
                let resetY = (isNeedReload) ? self.contentView.bounds.height * 1.2 : 0
            
                UIView.animate(withDuration: 0.3, animations: {
                    self.layer.transform = CATransform3DMakeTranslation(0, resetY, 0)
                
                    }, completion: { (finish) in
                        if let reload = self.reloadBlock , isNeedReload ,finish {
                            reload()
                        }
                })
        }
    }
    
    open override func awakeFromNib() {
    
        super.awakeFromNib()
        self.layer.speed = 0.8

        if pangesture == nil {
            pangesture = UIPanGestureRecognizer(target: self,action: #selector(CardCell.pan(rec:)))
            pangesture!.delegate = self
            self.addGestureRecognizer(pangesture!)
        }
        
        self.setShadow(offset: CGSize(width: 0, height: -2), radius: 8, opacity: 0.5)
    }

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layer.zPosition = CGFloat(layoutAttributes.zIndex)
        if let layout = layoutAttributes as? CardLayoutAttributes {
            customCardLayout = layout
        }
        
    }
}

extension CardCell:UIGestureRecognizerDelegate {
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let layout = customCardLayout , layout.isExpand  {
            return layout.isExpand
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let layout = customCardLayout , layout.isExpand  {
            return layout.isExpand
        }
        return false
    }
}
