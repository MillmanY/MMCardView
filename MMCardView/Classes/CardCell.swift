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

public class CardCell:UICollectionViewCell{
    var collectionV:UICollectionView!
    var reloadBlock:(()->Void)?
    var customCardLayout:CardLayoutAttributes?
    var originTouchY:CGFloat = 0.0
    var pangesture:UIPanGestureRecognizer?
    func pan(rec:UIPanGestureRecognizer){
        let point = rec.locationInView(collectionV)
        let shiftY:CGFloat = (point.y - originTouchY  > 0) ? point.y - originTouchY : 0
        
        switch rec.state {
            case .Began:
                originTouchY = point.y
            case .Changed:
                self.transform = CGAffineTransformMakeTranslation(0, shiftY)

            default:
                let isNeedReload = (shiftY > self.contentView.frame.height/3) ? true : false
                let resetY = (isNeedReload) ? self.contentView.bounds.height * 1.2 : 0
            
                
                UIView.animateWithDuration(0.3, animations: { 
                    self.layer.transform = CATransform3DMakeTranslation(0, resetY, 0)

                    }, completion: { (finish) in
                        if let reload = self.reloadBlock  where isNeedReload && finish {
                            reload()
                        }

                })
        }
    }
    
     override public func awakeFromNib() {
    
        super.awakeFromNib()
        self.layer.speed = 0.8

        if pangesture == nil {
            pangesture = UIPanGestureRecognizer.init(target: self, action: #selector(CardCell.pan(_:)))
            pangesture!.delegate = self
            self.addGestureRecognizer(pangesture!)
        }
        
        self.setShadow(CGSize(width: 0, height: -2), radius: 8, opacity: 0.5)
    }
    
    override public func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        if let layout = layoutAttributes as? CardLayoutAttributes {
            customCardLayout = layout
            
        }
    }
}

extension CardCell:UIGestureRecognizerDelegate {
    
     override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let layout = customCardLayout  where layout.isExpand  {
            return layout.isExpand
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let layout = customCardLayout  where layout.isExpand  {
            return layout.isExpand
        }
        return false
    }
}
