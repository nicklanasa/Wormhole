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
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.repliesLabel.layer.cornerRadius = 2
        self.repliesLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.commentTextView.delegate = self
    }
    
    var link: RKLink! {
        didSet {
            
            var selfText = ""
            
            if link.selfPost && count(link.selfText) > 0 {
                selfText = "\n\n\(link.selfText))"
            }
            
            var parser = XNGMarkdownParser()
            parser.paragraphFont = MyRedditSelfTextFont
            parser.boldFontName = MyRedditCommentTextBoldFont.familyName
            parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
            parser.italicFontName = MyRedditCommentTextItalicFont.familyName
            parser.linkFontName = MyRedditCommentTextBoldFont.familyName
            
            var parsedString = NSMutableAttributedString(attributedString: parser.attributedStringFromMarkdownString("\(link.title)\(selfText)"))
            var titleAttr = [NSForegroundColorAttributeName : UIColor.blackColor()]
            var selfTextAttr = [NSForegroundColorAttributeName : UIColor.darkGrayColor()]
            parsedString.addAttributes(selfTextAttr, range: NSMakeRange(0, count(parsedString.string)))
            parsedString.addAttributes(titleAttr, range: NSMakeRange(0, count(link.title)))
            
            self.commentTextView.attributedText = parsedString
            
            var timeAgo = link.created.timeAgo()
            
            var replies = link.totalComments == 1 ? "reply" : "replies"
            
            var infoString = NSMutableAttributedString(string: "\(link.author) - \(timeAgo) - \(link.totalComments) \(replies)")
            var attrs = [NSForegroundColorAttributeName : UIColor.blackColor()]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(link.author)))
            
            self.infoLabel.attributedText = infoString
            
            self.repliesLabel.hidden = true
            
            repliesLabelHeightConstraint.constant = 0.0
            self.contentView.layoutIfNeeded()
        }
    }
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var comment: RKComment! {
        didSet {
            
            var parser = XNGMarkdownParser()
            parser.paragraphFont = MyRedditCommentTextFont
            parser.boldFontName = MyRedditCommentTextBoldFont.familyName
            parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
            parser.italicFontName = MyRedditCommentTextItalicFont.familyName
            parser.linkFontName = MyRedditCommentTextBoldFont.familyName
            
            var parsedString = NSMutableAttributedString(attributedString: parser.attributedStringFromMarkdownString(comment.body))
            self.commentTextView.attributedText = parsedString
            
            var timeAgo = comment.created.timeAgo()
            
            var infoString = NSMutableAttributedString(string: "\(comment.author) - \(timeAgo)")
            var attrs = [NSForegroundColorAttributeName : UIColor.blackColor()]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(comment.author)))
            
            self.infoLabel.attributedText = infoString
            
            if comment.replies.count > 0 {
                
                var lastReply = comment.replies[comment.replies.count - 1] as! RKComment
                
                var replies = comment.replies.count == 1 ? "reply" : "replies"
                var repliesString = NSMutableAttributedString(string: "   \(lastReply.author) replied | \(comment.replies.count) \(replies)")
                var attrs = [NSForegroundColorAttributeName : UIColor.blackColor()]
                repliesString.addAttributes(attrs, range: NSMakeRange(0, count(lastReply.author) + 3))
                
                self.repliesLabel.attributedText = repliesString
                self.repliesLabel.hidden = false
            } else {
                self.repliesLabel.hidden = true
                
                repliesLabelHeightConstraint.constant = 0.0
                self.contentView.layoutIfNeeded()
            }
        }
    }
    
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var repliesLabelHeightConstraint: NSLayoutConstraint!
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        self.commentDelegate?.commentCell(self, didTapLink: url)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        self.currentTappedURL = URL
        
        return false
    }
}