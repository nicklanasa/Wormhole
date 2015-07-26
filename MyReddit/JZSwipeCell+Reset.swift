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
        var indentPoints: CGFloat = CGFloat(self.indentationLevel) * self.indentationWidth
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.contentView.frame = CGRectMake(indentPoints,
                self.contentView.frame.origin.y,
                self.contentView.frame.size.width - indentPoints,
                self.contentView.frame.size.height)
            self.backgroundView?.backgroundColor = MyRedditBackgroundColor
        })
    }
}