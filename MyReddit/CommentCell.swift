//
//  CommentCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 4/27/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol CommentCellDelegate {
    func commentCell(cell: CommentCell, didTapLink link: NSURL)
}

class CommentCell: JZSwipeCell, UITextViewDelegate {
    
    var commentDelegate: CommentCellDelegate?
    
    var currentTappedURL: NSURL! {
        didSet {
            self.commentDelegate?.commentCell(self, didTapLink: self.currentTappedURL)
        }
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        var indentPoints: CGFloat = CGFloat(self.indentationLevel) * self.indentationWidth
        
        self.contentView.frame = CGRectMake(indentPoints,
            self.contentView.frame.origin.y,
            self.contentView.frame.size.width - indentPoints,
            self.contentView.frame.size.height)
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.shortSwipeLength = 300
        } else {
            self.shortSwipeLength = 150
        }
        
        var upVoteImage = UIImage(named: "Up")?.imageWithRenderingMode(.AlwaysOriginal)
        var downVoteImage = UIImage(named: "Down")?.imageWithRenderingMode(.AlwaysOriginal)
        var replyImage = UIImage(named: "Reply")?.imageWithRenderingMode(.AlwaysOriginal)
        
        self.imageSet = SwipeCellImageSetMake(downVoteImage, downVoteImage, upVoteImage, replyImage)
        self.colorSet = SwipeCellColorSetMake(MyRedditDownvoteColor, MyRedditDownvoteColor, MyRedditUpvoteColor, MyRedditReplyColor)
        
        self.commentTextView.delegate = self
        
        self.backgroundView?.backgroundColor = MyRedditBackgroundColor
        self.defaultBackgroundColor = MyRedditBackgroundColor
    }
    
    var link: RKLink! {
        didSet {
            
            var selfText = ""
            
            if link.selfPost && count(link.selfText) > 0 {
                selfText = "\n\n\(link.selfText))".stringByReplacingOccurrencesOfString("&gt;",
                    withString: ">",
                    options: nil,
                    range: nil)
            }
            
            var parser = XNGMarkdownParser()
            parser.paragraphFont = MyRedditSelfTextFont
            parser.boldFontName = MyRedditCommentTextBoldFont.familyName
            parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
            parser.italicFontName = MyRedditCommentTextItalicFont.familyName
            parser.linkFontName = MyRedditCommentTextBoldFont.familyName
            
            var title = link.title.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: nil, range: nil)
            
            var parsedString = NSMutableAttributedString(attributedString: parser.attributedStringFromMarkdownString("\(title)\(selfText)"))
            var titleAttr = [NSForegroundColorAttributeName : MyRedditLabelColor]
            var selfTextAttr = [NSForegroundColorAttributeName : MyRedditSelfTextLabelColor]
            parsedString.addAttributes(selfTextAttr, range: NSMakeRange(0, count(parsedString.string)))
            parsedString.addAttributes(titleAttr, range: NSMakeRange(0, count(link.title)))
            
            self.commentTextView.attributedText = parsedString
            
            var timeAgo = link.created.timeAgo()
            
            var infoString = NSMutableAttributedString(string: "/r/\(self.link.subreddit) | \(link.author) | \(timeAgo)")
            var attrs = [NSForegroundColorAttributeName : MyRedditLabelColor]
            var subAttrs = [NSForegroundColorAttributeName : MyRedditColor, NSFontAttributeName : MyRedditCommentInfoMediumFont]
            infoString.addAttributes(subAttrs, range: NSMakeRange(0, count("/r/\(self.link.subreddit)")))
            infoString.addAttributes(attrs, range: NSMakeRange(count("/r/\(self.link.subreddit) | "), count(link.author)))
            
            self.infoLabel.attributedText = infoString
            self.scoreLabel.text = link.score.description
                        
            if self.link.upvoted() {
                self.scoreLabel.textColor = MyRedditUpvoteColor
            } else if self.link.downvoted() {
                self.scoreLabel.textColor = MyRedditDownvoteColor
            } else {
                self.scoreLabel.textColor = UIColor.lightGrayColor()
            }
            
            self.commentTextView.font = UIFont(name: self.commentTextView.font.fontName,
                size: SettingsManager.defaultManager.titleFontSizeForDefaultTextSize)
            
            self.commentTextView.backgroundColor = MyRedditBackgroundColor
            self.contentView.backgroundColor = MyRedditBackgroundColor
        }
    }
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var comment: RKComment!
    
    func configueForComment(#comment: RKComment, isLinkAuthor: Bool) {
        
        self.comment = comment
        
        var parser = XNGMarkdownParser()
        parser.paragraphFont = MyRedditCommentTextFont
        parser.boldFontName = MyRedditCommentTextBoldFont.familyName
        parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
        parser.italicFontName = MyRedditCommentTextItalicFont.familyName
        parser.linkFontName = MyRedditCommentTextBoldFont.familyName
        
        var parsedString = NSMutableAttributedString(attributedString: parser.attributedStringFromMarkdownString(comment.body.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: nil, range: nil)))
        self.commentTextView.attributedText = parsedString
        
        var timeAgo = comment.created.timeAgo()
        
        var infoString = NSMutableAttributedString(string: "\(comment.author) - \(timeAgo)")
        var attrs = [NSForegroundColorAttributeName : isLinkAuthor ? MyRedditColor : MyRedditLabelColor]
        infoString.addAttributes(attrs, range: NSMakeRange(0, count(comment.author)))
        
        self.infoLabel.attributedText = infoString
        
        self.scoreLabel.text = comment.score.description
        
        if self.comment.upvoted() {
            self.scoreLabel.textColor = MyRedditUpvoteColor
        } else if self.comment.downvoted() {
            self.scoreLabel.textColor = MyRedditDownvoteColor
        } else {
            self.scoreLabel.textColor = UIColor.lightGrayColor()
        }
        
        self.commentTextView.font = UIFont(name: self.commentTextView.font.fontName,
            size: SettingsManager.defaultManager.titleFontSizeForDefaultTextSize)
        self.commentTextView.backgroundColor = MyRedditBackgroundColor
        self.commentTextView.textColor = MyRedditLabelColor
        self.contentView.backgroundColor = MyRedditBackgroundColor
    }
    
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        self.currentTappedURL = URL
        return false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.backgroundView?.backgroundColor = MyRedditBackgroundColor
        self.indentationLevel = 0
        self.indentationWidth = 0
        self.separatorInset = UIEdgeInsetsZero
    }
}