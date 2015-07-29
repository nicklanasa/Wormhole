//
//  UIApplication+RootViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa.
//  Copyright (c) 2015 Nytek Productions. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    /**
    Provides a convenience method for safely accessing the Window's
    rootViewController reference.
    */
    var rootViewController: UIViewController? {
        get {
            if let window = self.keyWindow {
                if let rootViewController = window.rootViewController {
                    return rootViewController
                }
                
                return window.subviews[0].nextResponder() as? UIViewController
            }
            return nil
        }
        
        set {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let window = self.keyWindow {
                    window.rootViewController = newValue
                }
            })
        }
    }
}