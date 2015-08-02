//
//  PostImageCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol PostImageCellDelegate {
    func postImageCell(cell: PostImageCell,
        didDownloadImageWithHeight height: CGFloat, url: NSURL)
}

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
    
    var postImageDelegate: PostImageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.resetViews()
    }
    
    private func resetViews() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.titleLabel.frame = CGRectMake(15, 25, self.contentView.frame.size.width - 20, 50)
            self.subredditLabel.frame = CGRectMake(15, 4, self.contentView.frame.size.width - 20, 21)
            self.scoreLabel.frame = CGRectMake(self.contentView.frame.size.width - 80, 4, 70, 18)
            self.postInfoLabel.frame = CGRectMake(15, self.contentView.frame.size.height - 25, self.contentView.frame.size.width - 20, 14)
        })
    }
    
    override var link: RKLink! {
        didSet {
            self.postImageView.alpha = 0.0
            
            var url: NSURL!
            
            if self.link.isImageLink() {
                url = self.link.URL
            } else if self.link.domain == "imgur.com" {
                if let absoluteString = self.link.URL.absoluteString {
                    var stringURL = absoluteString + ".jpg"
                    url = NSURL(string: stringURL)
                }
            }
            
            self.postImageView.sd_setImageWithURL(url, completed: { (image, error, cacheType, url) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.postImageView.alpha = 1.0
                        if error != nil {
                            self.postImageView.image = UIImage(named: "Reddit")
                            self.postImageView.contentMode = UIViewContentMode.ScaleAspectFit
                            self.resetViews()
                        } else {
                            if let resizedImage = image?.imageWithImage(image, convertToSize: self.postImageView.frame.size) {
                                self.postImageView.contentMode = UIViewContentMode.ScaleAspectFill
                                self.postImageView.image = resizedImage
                                self.postImageDelegate?.postImageCell(self, didDownloadImageWithHeight: resizedImage.size.height + 150, url: url)
                                self.resetViews()
                            } else {
                                self.postImageView.image = UIImage(named: "Reddit")
                                self.postImageView.contentMode = UIViewContentMode.ScaleToFill
                                self.resetViews()
                            }
                        }
                    })
                })
            })

            if self.link.upvoted() {
                self.scoreLabel.textColor = MyRedditUpvoteColor
            } else if self.link.downvoted() {
                self.scoreLabel.textColor = MyRedditDownvoteColor
            } else {
                self.scoreLabel.textColor = UIColor.lightGrayColor()
            }
            
            self.titleLabel.text = link.title
            self.scoreLabel.text = link.score.description
            self.subredditLabel.text = "/r/\(link.subreddit)"
           
            var showFlair = ""
            
            if SettingsManager.defaultManager.valueForSetting(.Flair) {
                if let flairString = link.linkFlairText {
                    showFlair = " | \(flairString)"
                }
            }
            
            if SettingsManager.defaultManager.valueForSetting(.Flair) {
                if let flairString = link.linkFlairText {
                    showFlair = "\(flairString) |"
                }
            }
            
            var infoString = NSMutableAttributedString(string:"\(showFlair) \(link.author) | \(link.created.timeAgoSimple()) | \(link.totalComments.description) comments")
            var attrs = [NSForegroundColorAttributeName : MyRedditLabelColor]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(showFlair) == 0 ? 0 : count(showFlair) - 1))
            
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
            
            self.resetViews()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetViews()
    }
}