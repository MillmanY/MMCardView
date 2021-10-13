//
//  UIViewExtension.swift
//  Pods
//
//  Created by MILLMAN on 2016/9/20.
//
//

import UIKit

extension UIView {
    
    func setShadow(offset:CGSize,radius:CGFloat,opacity:Float) {
     
        self.layer.masksToBounds = false
        self.layer.cornerRadius = radius
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
    }
    
}


