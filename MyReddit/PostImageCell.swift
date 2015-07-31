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
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var link: RKLink! {
        didSet {
            self.postImageView.alpha = 0.0
            
            if self.link.isImageLink() {
                SDWebImageDownloader.sharedDownloader().downloadImageWithURL(self.link.URL, options: SDWebImageDownloaderOptions.ContinueInBackground, progress: { (rSize, eSize) -> Void in
                    
                    }, completed: { (image, data, error, success) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                self.postImageView.alpha = 1.0
                                if error != nil {
                                    self.postImageView.image = UIImage(named: "Reddit")
                                    self.postImageView.contentMode = UIViewContentMode.ScaleAspectFit
                                } else {
                                    self.postImageView.image = image.resize(self.postImageView.frame.size)
                                    self.postImageView.contentMode = UIViewContentMode.ScaleToFill
                                }
                            })
                        })
                })
            } else if let media = self.link.media {
                if let thumbnailURL = media.thumbnailURL {
                    self.postImageView.sd_setImageWithURL(thumbnailURL, completed: { (image, error, cacheType, url) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                self.postImageView.alpha = 1.0
                                if error != nil {
                                    self.postImageView.image = UIImage(named: "Reddit")
                                    self.postImageView.contentMode = UIViewContentMode.ScaleAspectFit
                                } else {
                                    self.postImageView.image = image.resize(self.postImageView.frame.size)
                                    self.postImageView.contentMode = UIViewContentMode.ScaleToFill
                                }
                            })
                        })
                    })
                }
            } else if self.link.domain == "imgur.com" {
                if let absoluteString = self.link.URL.absoluteString {
                    var stringURL = absoluteString + ".jpg"
                    var imageURL = NSURL(string: stringURL)
                    
                    SDWebImageDownloader.sharedDownloader().downloadImageWithURL(imageURL, options: SDWebImageDownloaderOptions.ContinueInBackground, progress: { (rSize, eSize) -> Void in
                        
                        }, completed: { (image, data, error, success) -> Void in
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                UIView.animateWithDuration(0.3, animations: { () -> Void in
                                    self.postImageView.alpha = 1.0
                                    if error != nil {
                                        self.postImageView.image = UIImage(named: "Reddit")
                                        self.postImageView.contentMode = UIViewContentMode.ScaleAspectFit
                                    } else {
                                        self.postImageView.image = image.resize(self.postImageView.frame.size)
                                        self.postImageView.contentMode = UIViewContentMode.ScaleToFill
                                    }
                                })
                            })
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
            
            var infoString = NSMutableAttributedString(string:"\(link.domain) | \(link.author)\(showFlair) | \(link.created.timeAgoSimple())")
            var attrs = [NSForegroundColorAttributeName : MyRedditLabelColor]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(link.domain)))
            
            self.postInfoLabel.attributedText = infoString
            
            if self.link.stickied {
                self.stickyLabel.hidden = true
            } else {
                self.stickyLabel.hidden = true
            }
            
            self.titleLabel.font = UIFont(name: self.titleLabel.font.fontName,
                size: SettingsManager.defaultManager.titleFontSizeForDefaultTextSize)
            
            self.titleLabel.textColor = MyRedditLabelColor
            self.contentView.backgroundColor = MyRedditBackgroundColor
            
            if link.viewed() {
                self.titleLabel.textColor = UIColor.lightGrayColor()
            } else {
                self.titleLabel.textColor = MyRedditLabelColor
            }
            if let imageView = self.commentImageView {
                if SettingsManager.defaultManager.valueForSetting(.NightMode) {
                    imageView.image = UIImage(named: "ChatWhite")
                } else {
                    imageView.image = UIImage(named: "Chat")
                }
            }
        }
    }
}

