//
//  UIAlertController+Helpers.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/3/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController {
            presentFromController(rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
                presentFromController(visibleVC, animated: animated, completion: completion)
        } else
            if  let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                    presentFromController(selectedVC, animated: animated, completion: completion)
            } else {
                controller.presentViewController(self, animated: animated, completion: completion)
        }
    }
    
    class func saveImageAlertController(image: UIImage) -> UIAlertController {
        let alertController = UIAlertController(title: "Select action",
            message: nil,
            preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "copy image", style: .Default, handler: { (action) -> Void in
            UIPasteboard.generalPasteboard().image = image
        }))
        
        alertController.addAction(UIAlertAction(title: "save image", style: .Default, handler: { (action) -> Void in
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        
        return alertController
    }
}

extension UIAlertController {
    class func longHoldAlertControllerWithLink(link: RKLink, completion: (UIAlertAction) -> ()) -> UIAlertController {
        let alertController = UIAlertController(title: "Select action",
            message: nil,
            preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "copy link", style: .Default, handler: { (action) -> Void in
            UIPasteboard.generalPasteboard().URL = link.URL
            completion(action)
        }))
        
        alertController.addAction(UIAlertAction(title: "copy reddit post", style: .Default, handler: { (action) -> Void in
            UIPasteboard.generalPasteboard().URL = link.permalink
            completion(action)
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        
        return alertController
    }
    
    class func swipeMoreAlertControllerWithLink(link: RKLink, completion: (UIAlertAction) -> ()) -> UIAlertController {
        let alertController = UIAlertController(title: "Select action",
            message: nil,
            preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "hide", style: .Default, handler: { (action) -> Void in
            completion(action)
        }))
        
        if link.saved {
            alertController.addAction(UIAlertAction(title: "unsave", style: .Default, handler: { (action) -> Void in
                completion(action)
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "save", style: .Default, handler: { (action) -> Void in
                completion(action)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        
        return alertController
    }
    
    class func swipeShareAlertControllerWithLink(link: RKLink, completion: (url: NSURL, action: UIAlertAction) -> ()) -> UIAlertController {
        let alertController = UIAlertController(title: "share",
            message: link.title,
            preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "share link", style: .Default, handler: { (action) -> Void in
            completion(url: link.URL, action: action)
        }))
        
        alertController.addAction(UIAlertAction(title: "share reddit post", style: .Default, handler: { (action) -> Void in
            completion(url: link.permalink, action: action)
        }))
        
        if link.hasImage() {
            alertController.addAction(UIAlertAction(title: "share image", style: .Default, handler: { (action) -> Void in
                completion(url: link.URL, action: action)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        
        return alertController
    }
}