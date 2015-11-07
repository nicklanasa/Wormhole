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