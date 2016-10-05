//
//  UIViewControllerExtension.swift
//  Pods
//
//  Created by MILLMAN on 2016/9/5.
//

import UIKit
extension UIViewController{
    
    private static func findBestViewController(vc:UIViewController) -> UIViewController! {
        if((vc.presentedViewController) != nil){
            return UIViewController.findBestViewController(vc.presentedViewController!)
        }
            
        else if(vc.isKindOfClass(UISplitViewController.classForCoder())){
            let splite = vc as! UISplitViewController
            if(splite.viewControllers.count > 0){
                return UIViewController.findBestViewController(splite.viewControllers.last!)
            }
                
            else{
                return vc
            }
        }
            
        else if(vc.isKindOfClass(UINavigationController.classForCoder())){
            let svc = vc as! UINavigationController
            if(svc.viewControllers.count > 0){
                return UIViewController.findBestViewController(svc.topViewController!)
            }
            else{
                return vc
            }
        }
            
        else if(vc.isKindOfClass(UITabBarController.classForCoder())){
            let svc = vc as! UITabBarController
            if(svc.viewControllers?.count > 0){
                return UIViewController.findBestViewController(svc.selectedViewController!)
            }
            else{
                return vc
            }
        }
            
        else{
            return vc
        }
    }
    
    
    static func currentViewController() -> UIViewController {
        let vc:UIViewController! = UIApplication.sharedApplication().keyWindow?.rootViewController
        
        return UIViewController.findBestViewController(vc)
    }
}
