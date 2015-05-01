//
//  PostImageCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class PostImageCell: PostCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var subredditLabel: UILabel!
    
    override var link: RKLink! {
        didSet {
            if link.isImageLink() {
                self.postImageView.sd_setImageWithURL(link.URL)
            } else if let thumbnailURL = link.media.thumbnailURL {
                self.postImageView.sd_setImageWithURL(thumbnailURL)
            }
            
            if self.link.upvoted() {
                self.scoreLabel.textColor = MyRedditUpvoteColor
            } else if self.link.downvoted() {
                self.scoreLabel.textColor = MyRedditDownvoteColor
            } else {
                self.scoreLabel.textColor = UIColor.lightGrayColor()
            }
            
            self.titleLabel.text = link.title
            self.scoreLabel.text = link.score.description
            self.commentsLabel.text = link.totalComments.description
            self.subredditLabel.text = "/r/\(link.subreddit)"
           
            var infoString = NSMutableAttributedString(string:"\(link.domain) | \(link.author)")
            var attrs = [NSForegroundColorAttributeName : UIColor.blackColor()]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(link.domain)))
            
            self.postInfoLabel.attributedText = infoString
        }
    }
    
    override func prepareForReuse() {
        self.postImageView.image = nil
    }
}

