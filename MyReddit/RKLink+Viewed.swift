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
        if let savedLinked: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(self.identifier) {
            return true
        } else {
            return false
        }
    }
}