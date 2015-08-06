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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var subredditButton: UIButton!
    
    func subredditTap() {
        self.postCellDelegate?.postCell(self,
            didTapSubreddit: self.subredditButton.titleForState(.Normal))
    }
    
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
            
            self.subredditButton.setTitle("\(link.subreddit)", forState: .Normal)
            
            self.subredditButton.addTarget(self, action: "subredditTap", forControlEvents: .TouchUpInside)
            
            var showFlair = ""
            
            if SettingsManager.defaultManager.valueForSetting(.Flair) {
                if let flairString = link.linkFlairText {
                    if count(flairString) > 0 {
                        showFlair = "\(flairString) |"
                    }
                }
            }
            
            var infoString = NSMutableAttributedString(string:"\(showFlair) \(link.author) | \(link.created.timeAgoSimple()) | \(link.totalComments.description) comments")
            var attrs = [NSForegroundColorAttributeName : MyRedditLabelColor]
            var commentsAttr = [NSForegroundColorAttributeName : MyRedditColor]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(showFlair) == 0 ? 0 : count(showFlair) - 1))
            infoString.addAttributes(commentsAttr, range: NSMakeRange(count(infoString.string) - count("\(link.totalComments.description) comments"), count("\(link.totalComments.description) comments")))
            
            self.postInfoLabel.attributedText = infoString
            
            self.titleLabel.font = UIFont(name: self.titleLabel.font.fontName,
                size: SettingsManager.defaultManager.titleFontSizeForDefaultTextSize)
            
            self.titleLabel.textColor = MyRedditLabelColor
            self.contentView.backgroundColor = MyRedditBackgroundColor
            
            if link.viewed() {
                self.titleLabel.textColor = UIColor.lightGrayColor()
            } else {
                self.titleLabel.textColor = MyRedditLabelColor
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
            
            self.subredditButton.hidden = true
            
            var replies = linkComment.replies?.count == 1 ? "reply" : "replies"
            
            var infoString = NSMutableAttributedString(string: "\(linkComment.author) - \(linkComment.created.timeAgoSimple()) - \(linkComment.replies?.count ?? 0) \(replies)")

            var attrs = [NSForegroundColorAttributeName : MyRedditLabelColor]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(linkComment.author)))
            
            self.postInfoLabel.attributedText = infoString
            
            self.titleLabel.textColor = MyRedditLabelColor
            self.contentView.backgroundColor = MyRedditBackgroundColor
        }
    }
    
    override func upvote() {
        if self.link.upvoted() {
            self.unvote()
        } else {
            self.scoreLabel.textColor = MyRedditUpvoteColor
        }
    }
    
    override func downvote() {
        if self.link.upvoted() {
            self.unvote()
        } else {
            self.scoreLabel.textColor = MyRedditDownvoteColor
        }
    }
    
    override func unvote() {
        self.scoreLabel.textColor = UIColor.lightGrayColor()
    }
}