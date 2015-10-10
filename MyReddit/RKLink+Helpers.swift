//
//  RKLink+Viewed.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/5/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension RKLink {
    func viewed() -> Bool {
        if let _: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(self.identifier) {
            return true
        } else {
            return false
        }
    }
    
    func saved() -> Bool {
        if let _: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(self.identifier + "saved") {
            return true
        } else {
            return false
        }
    }
    
    func saveLink() {
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: self.identifier + "saved")
    }
    
    func unSaveLink() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: self.identifier + "saved")
    }
    
    func isHidden() -> Bool {
        if let _: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(self.identifier + "hidden") {
            return true
        } else {
            if self.hidden {
                return true
            }
            return false
        }
    }
    
    func hideLink() {
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: self.identifier + "hidden")
    }
    
    func unHideink() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: self.identifier + "hidden")
    }
}