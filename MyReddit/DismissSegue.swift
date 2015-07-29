//
//  DismissSegue.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 7/28/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {
    
    override func perform() {
        var sourceView = self.sourceViewController.view as UIView!
        var destView = self.destinationViewController.view as UIView!
        
        destView.alpha = 0.0
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(destView, aboveSubview: sourceView)
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            destView.alpha = 1.0
            sourceView.alpha = 0.0
        }) { (Finished) -> Void in
            UIApplication.sharedApplication().rootViewController = self.destinationViewController as? UIViewController
        }
    }
}