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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var subredditButton: UIButton!
    
    var postImageDelegate: PostImageCellDelegate?
    
    func subredditTap() {
        self.postCellDelegate?.postCell?(self,
            didTapSubreddit: self.subredditButton.titleForState(.Normal))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.resetViews()
    }
    
    private func resetViews() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.titleLabel.frame = CGRectMake(14, 30, self.contentView.frame.size.width - 20, 50)
            self.subredditButton.frame = CGRectMake(14, 1, self.contentView.frame.size.width - 20, 30)
            self.scoreLabel.frame = CGRectMake(self.contentView.frame.size.width - 78, 6, 70, 18)
            self.postInfoLabel.frame = CGRectMake(15, self.contentView.frame.size.height - 25, self.contentView.frame.size.width - 20, 14)
        })
    }
    
    override var link: RKLink! {
        didSet {
            self.postImageView.alpha = 0.0
            if let url = link.urlForLink() {
                self.postImageView.sd_setImageWithURL(NSURL(string: url), completed: { (image, error, cacheType, url) -> Void in
                    self.postImageView.alpha = 1.0
                    if error != nil {
                        self.postImageView.image = UIImage(named: "Reddit")
                        self.postImageView.contentMode = UIViewContentMode.ScaleAspectFit
                        self.resetViews()
                    } else {
                        if let resizedImage = image?.imageWithImage(image, toSize: self.postImageView.frame.size) {
                            self.postImageView.contentMode = UIViewContentMode.ScaleAspectFill
                            self.postImageView.image = resizedImage
                            self.postImageDelegate?.postImageCell?(self, didDownloadImageWithHeight: resizedImage.size.height + 123, url: url)
                            self.resetViews()
                        } else {
                            self.postImageView.image = UIImage(named: "Reddit")
                            self.postImageView.contentMode = UIViewContentMode.ScaleToFill
                            self.resetViews()
                        }
                    }
                })
            } else {
                self.postImageView.image = UIImage(named: "Reddit")
                self.postImageView.contentMode = UIViewContentMode.ScaleAspectFit
                self.resetViews()
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