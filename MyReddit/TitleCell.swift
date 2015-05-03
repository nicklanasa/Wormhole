//
//  TitleCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class TitleCell: PostCell {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var stickyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var link: RKLink! {
        didSet {
            self.titleLabel.text = link.title
            self.scoreLabel.text = link.score.description
            
            if self.link.upvoted() {
                self.scoreLabel.textColor = MyRedditUpvoteColor
            } else if self.link.downvoted() {
                self.scoreLabel.textColor = MyRedditDownvoteColor
            } else {
                self.scoreLabel.textColor = UIColor.lightGrayColor()
            }
            
            self.commentsLabel.text = link.totalComments.description
            self.subredditLabel.text = "/r/\(link.subreddit)"
            
            var showFlair = ""
            
            if SettingsManager.defaultManager.valueForSetting(.Flair) {
                if let flairString = link.linkFlairText {
                    showFlair = " | \(flairString)"
                }
            }
            
            var infoString = NSMutableAttributedString(string: "\(link.domain) | \(link.author)")
            var attrs = [NSForegroundColorAttributeName : MyRedditLabelColor]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(link.domain)))
            
            var flairAttrs = [NSForegroundColorAttributeName : MyRedditColor]
            infoString.addAttributes(flairAttrs, range: NSMakeRange(infoString.length - count(showFlair) + 1, count(showFlair)))
            
            self.postInfoLabel.attributedText = infoString
            
            if self.link.stickied {
                self.stickyLabel.hidden = false
            } else {
                self.stickyLabel.hidden = true
            }
        }
    }
    
    override var linkComment: RKComment! {
        didSet {
            self.titleLabel.text = linkComment.body
            self.scoreLabel.text = linkComment.score.description
            
            if self.linkComment.upvoted() {
                self.scoreLabel.textColor = MyRedditUpvoteColor
            } else if self.linkComment.downvoted() {
                self.scoreLabel.textColor = MyRedditDownvoteColor
            } else {
                self.scoreLabel.textColor = UIColor.lightGrayColor()
            }
            
            self.commentsLabel.text = linkComment.replies?.count.description
            self.subredditLabel.text = "/r/\(linkComment.subreddit)"
            
            var replies = linkComment.replies?.count == 1 ? "reply" : "replies"
            
            var infoString = NSMutableAttributedString(string: "\(linkComment.author) - \(linkComment.created.timeAgo()) - \(linkComment.replies?.count) \(replies)")

            var attrs = [NSForegroundColorAttributeName : MyRedditLabelColor]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(linkComment.author)))
            
            self.postInfoLabel.attributedText = infoString
        }
    }
}