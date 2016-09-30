//
//  CustomFlipTransition.swift
//  Pods
//
//  Created by MILLMAN on 2016/9/21.
//
//

import UIKit

enum TransitionMode: Int {
    case Present, Dismiss
}

public class CustomFlipTransition: NSObject,UIViewControllerAnimatedTransitioning {
    var duration = 0.3
    var transitionMode:TransitionMode = .Present
    var cardView:UICollectionViewCell!
    var originalCardFrame = CGRect.zero
    lazy var blurView:UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.0
        return blurEffectView
    }()
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        let viewRadius = self.cardView.layer.cornerRadius
        
        if self.transitionMode == .Present {
         
            originalCardFrame = self.cardView.frame
            let toViewF = self.cardView.convert(self.cardView.superview!.frame, to: toView!)
            toView?.frame = self.cardView.bounds
            toView?.layer.cornerRadius = viewRadius
            self.cardView.addSubview(toView!)
            self.blurView.frame = containerView.bounds
            self.blurView.alpha = 0.0
            containerView.addSubview(self.blurView)

            UIView.transition(with: self.cardView, duration: 0.7, options: [.transitionFlipFromRight,.curveEaseIn], animations: {
                self.cardView.frame = CGRect.init(x: self.originalCardFrame.origin.x, y: self.originalCardFrame.origin.y, width: toViewF.width, height: toViewF.height)
                }, completion: { (finish) in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.blurView.alpha = 1.0
                    })
                    
                    toView?.frame = toViewF
                    toView?.removeFromSuperview()
                    containerView.addSubview(toView!)
                    transitionContext.completeTransition(true)
            })
        } else {
            self.cardView.isHidden = true
            let content = self.cardView.contentView
            let originalCrolor = content.backgroundColor
            content.backgroundColor = self.cardView.backgroundColor
            content.layer.cornerRadius = viewRadius
            fromView?.addSubview(content)
            UIView.transition(with: fromView!, duration: 0.7, options: [.transitionFlipFromLeft,.curveEaseInOut], animations: {
                fromView?.frame = CGRect.init(x: fromView!.frame.origin.x, y: fromView!.frame.origin.y, width: self.originalCardFrame.width, height: self.originalCardFrame.height)
                content.frame = CGRect.init(x: fromView!.frame.origin.x, y: fromView!.frame.origin.y, width: self.originalCardFrame.width, height: self.originalCardFrame.height)
                self.cardView.frame = CGRect.init(x: 0, y: self.originalCardFrame.origin.y, width: self.originalCardFrame.width, height: self.originalCardFrame.height)
                self.blurView.alpha = 0.0

                }, completion: { (finish) in
                    self.blurView.removeFromSuperview()
                    content.backgroundColor = originalCrolor
                    content.removeFromSuperview()
                    self.cardView.addSubview(content)
                    self.cardView.isHidden = false
                    transitionContext.completeTransition(true)
            })
        }
    }
    
    public convenience init(duration:TimeInterval) {
        self.init()
        self.duration = duration
    }
}
