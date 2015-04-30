//
//  JZSwipeCell+Reset.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/30/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension JZSwipeCell {
    func reset() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.contentView.center = CGPointMake(self.contentView.frame.size.width / 2, self.contentView.center.y)
        })
    }
}