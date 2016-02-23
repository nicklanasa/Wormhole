//
//  PostImageCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PostImageCellDelegate {
    optional func postImageCell(cell: PostImageCell,
        didDownloadImageWithHeight height: CGFloat, url: NSURL)
    optional func postImageCell(cell: PostImageCell, didLongHoldOnImage image: UIImage?)
}

class PostImageCell: PostCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var postInfoLabel: UILabel!
    
    var postImageDelegate: PostImageCellDelegate?
    
    func subredditTap() {
        self.postCellDelegate?.postCell?(self,
            didTapSubreddit: self.subredditButton.titleForState(.Normal))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleTextView.userInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override var link: RKLink! {
        didSet {
            self.postImageView.alpha = 0.0
            if let url = link.urlForLink() {
                self.postImageView.sd_setImageWithURL(NSURL(string: url),
                    completed: { (image, error, cacheType, url) -> Void in
                    self.postImageView.alpha = 1.0
                    if error != nil {
                        self.postImageView.image = UIImage(named: "Reddit")
                    } else {
                        self.postImageView.image = image
                    }
                })
            } else {
                self.postImageView.image = UIImage(named: "Reddit")
            }

            if self.link.upvoted() {
                self.scoreLabel.textColor = MyRedditUpvoteColor
            } else if self.link.downvoted() {
                self.scoreLabel.textColor = MyRedditDownvoteColor
            } else {
                self.scoreLabel.textColor = UIColor.lightGrayColor()
            }
            
            self.titleTextView.text = link.title
            self.scoreLabel.text = link.score.description
            self.subredditButton.setTitle("\(link.subreddit)", forState: .Normal)
            
            self.subredditButton.addTarget(self, action: "subredditTap", forControlEvents: .TouchUpInside)
           
            var showFlair = ""
            
            if SettingsManager.defaultManager.valueForSetting(.Flair) {
                if let flairString = link.linkFlairText {
                    if flairString.characters.count > 0 {
                        showFlair = "\(flairString) |"
                    }
                }
            }
            
            let infoString = NSMutableAttributedString(string:"\(showFlair) \(link.author) | \(link.created.timeAgoSinceNow()) | \(link.totalComments.description) comments")
            let attrs = [NSForegroundColorAttributeName : MyRedditLabelColor]
            let commentsAttr = [NSForegroundColorAttributeName : MyRedditColor]
            infoString.addAttributes(attrs, range: NSMakeRange(0, showFlair.characters.count == 0 ? 0 : showFlair.characters.count - 1))
            infoString.addAttributes(commentsAttr,
                range: NSMakeRange(infoString.string.characters.count - "\(link.totalComments.description) comments".characters.count, "\(link.totalComments.description) comments".characters.count))
            
            self.postInfoLabel.attributedText = infoString
            self.titleTextView.font = UIFont(name: MyRedditTitleFont.fontName,
                size: SettingsManager.defaultManager.titleFontSizeForDefaultTextSize)
            
            self.titleTextView.textColor = MyRedditLabelColor
            self.contentView.backgroundColor = MyRedditBackgroundColor
            
            if link.viewed() {
                self.titleTextView.textColor = UIColor.lightGrayColor()
            } else {
                self.titleTextView.textColor = MyRedditLabelColor
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}