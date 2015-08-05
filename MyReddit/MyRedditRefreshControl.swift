//
//  MyRedditRefreshControl.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 8/1/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit
import Foundation

class MyRedditRefreshControl: JHRefreshControl {
    
    var index: Int = 0
    var colors: [UIColor] = [MyRedditUpvoteColor, MyRedditDownvoteColor, MyRedditReplyColor, MyRedditColor]
    var label: UILabel!
    
    override func handleScrollingOnAnimationView(animationView: UIView!, withPullDistance pullDistance: CGFloat, pullRatio: CGFloat, pullVelocity: CGFloat) {
        if pullVelocity > 0.0 || pullRatio > 1.0 || pullDistance > self.height {
            self.endRefreshing()
        }
    }
    
    override func resetAnimationView(animationView: UIView!) {
        self.label.text = "refresh"
    }
    
    override func setupRefreshControlForAnimationView(animationView: UIView!) {
        index++
        if self.index == self.colors.count {
            self.index = 0
        }
        
        self.label.text = "refreshing"
    }
    
    override func animationCycleForAnimationView(animationView: UIView!) {
        self.backgroundColor = self.colors[self.index]
    }
    
    override func setup() {
        self.index = 0
        self.backgroundColor = self.colors[index]
        
        self.label = UILabel(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        self.label.font = MyRedditSelfTextFont
        self.label.text = "refresh"
        self.label.textColor = UIColor.whiteColor()
        self.label.textAlignment = .Center
        self.addSubviewToRefreshAnimationView(self.label)
    }
    
    override var height: CGFloat {
        get {
            return 70.0
        }
    }
    
    override var animationDuration: NSTimeInterval {
        get {
            return 0.3
        }
    }
    
    override var animationDelay: NSTimeInterval {
        get {
            return 0.0
        }
    }
}
