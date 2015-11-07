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
    
    var lines = [UIView]()
    var commentDelegate: CommentCellDelegate?
    
    var currentTappedURL: NSURL! {
        didSet {
            self.commentDelegate?.commentCell(self, didTapLink: self.currentTappedURL)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.setNeedsUpdateConstraints()
        self.contentView.setNeedsLayout()
        
        if self.lines.count == 0 {
            for var i = 1; i < self.indentationLevel; i++ {
                let lineView = UIView(frame: CGRectMake(CGFloat(i * 15), 5, 1, self.frame.size.height - 5))
                lineView.backgroundColor = MyRedditCommentLinesColor
                self.lines.append(lineView)
                self.contentView.addSubview(lineView)
            }
        }
        
        self.commentTextView.backgroundColor = MyRedditBackgroundColor
        self.contentView.backgroundColor = MyRedditBackgroundColor
        self.backgroundColor = MyRedditBackgroundColor
    }
    
    override func awakeFromNib() {
    
        super.awakeFromNib()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.shortSwipeLength = 300
        } else {
            self.shortSwipeLength = 150
        }
        
        let upVoteImage = UIImage(named: "Up")?.imageWithRenderingMode(.AlwaysOriginal)
        let downVoteImage = UIImage(named: "Down")?.imageWithRenderingMode(.AlwaysOriginal)
        let replyImage = UIImage(named: "moreWhite")?.imageWithRenderingMode(.AlwaysOriginal)
        
        self.imageSet = SwipeCellImageSetMake(downVoteImage, downVoteImage, upVoteImage, replyImage)
        self.colorSet = SwipeCellColorSetMake(MyRedditDownvoteColor, MyRedditDownvoteColor, MyRedditUpvoteColor, MyRedditReplyColor)
        
        self.commentTextView.delegate = self
        
        self.contentView.backgroundColor = MyRedditBackgroundColor
        self.backgroundColor = MyRedditBackgroundColor
        self.defaultBackgroundColor = MyRedditBackgroundColor
        self.commentTextView.textColor = MyRedditLabelColor
    }
    
    var link: RKLink! {
        didSet {
            
            var selfText = ""
            
            if link.selfPost && link.selfText.characters.count > 0 {
                selfText = "\n\n\(link.selfText)".stringByReplacingOccurrencesOfString("&gt;",
                    withString: ">",
                    options: .CaseInsensitiveSearch,
                    range: nil)
            }
            
            let parser = XNGMarkdownParser()
            parser.paragraphFont = MyRedditSelfTextFont
            parser.boldFontName = MyRedditCommentTextBoldFont.familyName
            parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
            parser.italicFontName = MyRedditCommentTextItalicFont.familyName
            parser.linkFontName = MyRedditCommentTextBoldFont.familyName
            
            let title = link.title.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: .CaseInsensitiveSearch, range: nil)
            
            let parsedString = NSMutableAttributedString(attributedString: parser.attributedStringFromMarkdownString("\(title)\(selfText)"))
            let titleAttr = [NSForegroundColorAttributeName : MyRedditLabelColor]
            let selfTextAttr = [NSForegroundColorAttributeName : MyRedditSelfTextLabelColor]
            let fontAttr = [NSFontAttributeName : MyRedditSelfTextFont]
            parsedString.addAttributes(selfTextAttr, range: NSMakeRange(0, parsedString.string.characters.count))
            parsedString.addAttributes(titleAttr, range: NSMakeRange(0, link.title.characters.count))
            parsedString.addAttributes(fontAttr, range: NSMakeRange(0, parsedString.string.characters.count))
            self.commentTextView.attributedText = parsedString
            
            let timeAgo = link.created.timeAgoSinceNow()
            
            let infoString = NSMutableAttributedString(string: "/r/\(self.link.subreddit) | \(link.author) | \(timeAgo)")
            let attrs = [NSForegroundColorAttributeName : MyRedditLabelColor]
            let subAttrs = [NSForegroundColorAttributeName : MyRedditColor, NSFontAttributeName : MyRedditCommentInfoMediumFont]
            infoString.addAttributes(subAttrs, range: NSMakeRange(0, "/r/\(self.link.subreddit)".characters.count))
            infoString.addAttributes(attrs, range: NSMakeRange("/r/\(self.link.subreddit) | ".characters.count, link.author.characters.count))
            
            self.infoLabel.attributedText = infoString
            self.scoreLabel.text = link.score.description
                        
            if self.link.upvoted() {
                self.scoreLabel.textColor = MyRedditUpvoteColor
            } else if self.link.downvoted() {
                self.scoreLabel.textColor = MyRedditDownvoteColor
            } else {
                self.scoreLabel.textColor = UIColor.lightGrayColor()
            }
            
            self.commentTextView.backgroundColor = MyRedditBackgroundColor
            self.contentView.backgroundColor = MyRedditBackgroundColor
            
            self.leadingTextViewConstraint.constant = 15
            self.leadinginfoLabelConstraint.constant = 15
        }
    }
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var comment: RKComment!
    
    func configueForComment(comment comment: RKComment, isLinkAuthor: Bool) {
        
        self.comment = comment
        
        let body = comment.body.stringByReplacingOccurrencesOfString("&gt;", withString: ">",
            options: .CaseInsensitiveSearch,
            range: nil).stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: .CaseInsensitiveSearch, range: nil)
        
        let parser = XNGMarkdownParser()
        parser.paragraphFont = UIFont(name: self.commentTextView.font!.fontName,
            size: SettingsManager.defaultManager.commentFontSizeForDefaultTextSize)
        parser.boldFontName = MyRedditCommentTextBoldFont.familyName
        parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
        parser.italicFontName = MyRedditCommentTextItalicFont.familyName
        parser.linkFontName = MyRedditCommentTextBoldFont.familyName
        
        let parsedString = NSMutableAttributedString(attributedString: parser.attributedStringFromMarkdownString("\(body)"))
        parsedString.addAttribute(NSForegroundColorAttributeName,
            value: MyRedditLabelColor,
            range: NSMakeRange(0, parsedString.string.characters.count))
        
        if parsedString.string.localizedCaseInsensitiveContainsString(">") {
            do {
                let regex = try NSRegularExpression(pattern: ">(.*)\\b\\n", options: .CaseInsensitive)
                regex.enumerateMatchesInString(body,
                    options: .Anchored,
                    range: NSMakeRange(0, body.characters.count),
                    usingBlock: { (result, flags, error) -> Void in
                    if let foundRange = result?.range {
                        parsedString.addAttribute(NSForegroundColorAttributeName,
                            value: UIColor.lightGrayColor(),
                            range: foundRange)
                    }
                })
            } catch {}
        }
        
        self.commentTextView.attributedText = parsedString
        
        let timeAgo = self.comment.created.timeAgoSinceNow()
        
        let info = "\(comment.author) - \(timeAgo)"
       
        if isLinkAuthor {
            let infoString = NSMutableAttributedString(string: info)
            let attrs = [NSForegroundColorAttributeName : isLinkAuthor ? MyRedditColor : MyRedditLabelColor, NSFontAttributeName : MyRedditCommentInfoMediumFont]
            infoString.addAttributes(attrs, range: NSMakeRange(0, comment.author.characters.count))
            self.infoLabel.attributedText = infoString
        } else {
            self.infoLabel.text = info
        }
        
        self.scoreLabel.text = comment.score.description
        
        if self.comment.upvoted() {
            self.scoreLabel.textColor = MyRedditUpvoteColor
        } else if self.comment.downvoted() {
            self.scoreLabel.textColor = MyRedditDownvoteColor
        } else {
            self.scoreLabel.textColor = UIColor.lightGrayColor()
        }
    
        self.commentTextView.font = UIFont(name: self.commentTextView.font!.fontName,
            size: SettingsManager.defaultManager.commentFontSizeForDefaultTextSize)
        self.commentTextView.backgroundColor = MyRedditBackgroundColor
        self.contentView.backgroundColor = MyRedditBackgroundColor
        self.infoLabel.backgroundColor = MyRedditBackgroundColor
        
        let indentPoints: CGFloat = CGFloat(self.indentationLevel) * self.indentationWidth
        self.leadingTextViewConstraint.constant = indentPoints
        self.leadinginfoLabelConstraint.constant = indentPoints
        
        for view in self.lines {
            view.backgroundColor = MyRedditCommentLinesColor
        }
    }
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var leadingTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadinginfoLabelConstraint: NSLayoutConstraint!
    
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        self.currentTappedURL = URL
        return false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        for view in self.lines {
            view.removeFromSuperview()
        }
        
        self.lines = [UIView]()
        self.indentationLevel = 0
        self.indentationWidth = 0
        self.separatorInset = UIEdgeInsetsZero
    }
}