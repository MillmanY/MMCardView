//
//  UIViewControllerExtension.swift
//  Pods
//
//  Created by MILLMAN on 2016/9/21.
//
//


import UIKit
extension UIViewController{
    
    fileprivate static func findBestViewController(_ vc:UIViewController) -> UIViewController! {
        if((vc.presentedViewController) != nil){
            return UIViewController.findBestViewController(vc.presentedViewController!)
        }
            
        else if(vc.isKind(of: UISplitViewController.classForCoder())){
            let splite = vc as! UISplitViewController
            if(splite.viewControllers.count > 0){
                return UIViewController.findBestViewController(splite.viewControllers.last!)
            }
                
            else{
                return vc
            }
        }
            
        else if(vc.isKind(of:UINavigationController.classForCoder())){
            let svc = vc as! UINavigationController
            if(svc.viewControllers.count > 0){
                return UIViewController.findBestViewController(svc.topViewController!)
            }
            else{
                return vc
            }
        }
            
        else if(vc.isKind(of:UITabBarController.classForCoder())){
            if let svc = vc as? UITabBarController,let v = svc.viewControllers , v.count > 0{
                return UIViewController.findBestViewController(svc.selectedViewController!)

            } else{
                return vc
            }
        }
            
        else{
            return vc
        }
    }
    
    static func currentViewController() -> UIViewController {
        let vc:UIViewController! = UIApplication.shared.keyWindow?.rootViewController
        return UIViewController.findBestViewController(vc)
    }
}
