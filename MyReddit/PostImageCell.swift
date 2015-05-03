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
    @IBOutlet weak var stickyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var link: RKLink! {
        didSet {
            if link.isImageLink() {
                self.postImageView.sd_setImageWithURL(link.URL)
            } else if let media = link.media {
                if let thumbnailURL = media.thumbnailURL {
                    self.postImageView.sd_setImageWithURL(thumbnailURL)
                }
            } else if link.domain == "imgur.com" {
                if let absoluteString = link.URL.absoluteString {
                    var stringURL = absoluteString + ".jpg"
                    var imageURL = NSURL(string: stringURL)
                    self.postImageView.sd_setImageWithURL(imageURL, placeholderImage: UIImage(), completed: { (image, error, cacheType, url) -> Void in
                        if error != nil {
                            self.postImageView.image = UIImage(named: "Reddit")
                        }
                    })
                }
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
           
            var showFlair = ""
            
            if SettingsManager.defaultManager.valueForSetting(.Flair) {
                if let flairString = link.linkFlairText {
                    showFlair = " | \(flairString)"
                }
            }
            
            var infoString = NSMutableAttributedString(string:"\(link.domain) | \(link.author)\(showFlair)")
            var attrs = [NSForegroundColorAttributeName : MyRedditLabelColor]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(link.domain)))
            
            self.postInfoLabel.attributedText = infoString
            
            if self.link.stickied {
                self.stickyLabel.hidden = true
            } else {
                self.stickyLabel.hidden = true
            }
        }
    }
    
    override func prepareForReuse() {
        self.postImageView.image = nil
    }
}

