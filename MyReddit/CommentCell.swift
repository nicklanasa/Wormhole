//
//  CommentCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 4/27/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import TTTAttributedLabel

let parser = XNGMarkdownParser()

@objc protocol CommentCellDelegate {
    optional func commentCell(cell: CommentCell, didTapLink link: NSURL)
    optional func commentCell(cell: CommentCell, didShortRightSwipeForItem item: AnyObject)
    optional func commentCell(cell: CommentCell, didLongRightSwipeForItem item: AnyObject)
    optional func commentCell(cell: CommentCell, didShortLeftSwipeForItem item: AnyObject)
    optional func commentCell(cell: CommentCell, didLongLeftSwipeForItem item: AnyObject)
}

class CommentCell: SwipeCell,
SwipeCellDelegate,
TTTAttributedLabelDelegate {
    
    @IBOutlet weak var leadingCommentLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadinginfoLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var bodyLabel: TTTAttributedLabel!
    
    var comment: RKComment!
    var commentDelegate: CommentCellDelegate?

    var linkParser: XNGMarkdownParser! {
        get {
            let parser = XNGMarkdownParser()
            parser.paragraphFont = MyRedditSelfTextFont
            parser.boldFontName = MyRedditCommentTextBoldFont.familyName
            parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
            parser.italicFontName = MyRedditCommentTextItalicFont.familyName
            parser.linkFontName = MyRedditCommentTextBoldFont.familyName
            return parser
        }
    }
    
    var commentParser: XNGMarkdownParser! {
        get {
            let parser = XNGMarkdownParser()
            parser.paragraphFont = UIFont(name: "AvenirNext-Medium",
                                          size: SettingsManager.defaultManager.commentFontSizeForDefaultTextSize)
            parser.boldFontName = MyRedditCommentTextBoldFont.familyName
            parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
            parser.italicFontName = MyRedditCommentTextItalicFont.familyName
            parser.linkFontName = MyRedditCommentTextBoldFont.familyName
            return parser            
        }
    }

    func addLinks() {
        do {
            let range = NSMakeRange(0, self.bodyLabel.text!.characters.count)
            let detector = try! NSDataDetector(types: NSTextCheckingType.Link.rawValue)
            let matches = detector.matchesInString(self.bodyLabel.text!,
                                                   options: [],
                                                   range: range)
            for match in matches {
	            let str = (self.bodyLabel.text! as NSString).substringWithRange(match.range)
                if let url = NSURL(string: str) {
                    self.bodyLabel.addLinkToURL(url, withRange: match.range)
                }
            }
        }
    }

    func attributedLabel(label: TTTAttributedLabel, didSelectLinkWithURL url:  NSURL) {
        self.currentTappedURL = url
    }
    
    var currentTappedURL: NSURL! {
        didSet {
            if let url = self.currentTappedURL {
                self.commentDelegate?.commentCell?(self, didTapLink: url)
            }
        }
    }
    
    override func awakeFromNib() {
        let upVoteImage = UIImage(named: "Up")!.imageWithRenderingMode(.AlwaysOriginal)
        let downVoteImage = UIImage(named: "Down")!.imageWithRenderingMode(.AlwaysOriginal)
        let moreImage = UIImage(named: "moreWhite")!.imageWithRenderingMode(.AlwaysOriginal)
        
        self.images = [downVoteImage, downVoteImage, upVoteImage, moreImage]
        self.colors = [MyRedditDownvoteColor, MyRedditDownvoteColor, MyRedditUpvoteColor, MyRedditReplyColor]
        
        super.awakeFromNib()

        self.swipeDelegate = self
        self.bodyLabel.delegate = self
        self.bodyLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
       
        self.selectionStyle = .Default
        
        self.infoLabel.font = MyRedditCommentInfoFont
    }

    var link: RKLink! {
        didSet {
            
            // Title
            var selfText = ""
            
            if link.selfPost && link.selfText.characters.count > 0 {
                selfText = "\n\n\(link.selfText)".stringByReplacingOccurrencesOfString("&gt;",
                    withString: ">",
                    options: .CaseInsensitiveSearch,
                    range: nil)
            }
                       
            let title = link.title.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: .CaseInsensitiveSearch, range: nil)
            
            let parsedString = NSMutableAttributedString(attributedString: parser.attributedStringFromMarkdownString("\(title)\(selfText)"))
            let titleAttr = [NSForegroundColorAttributeName : MyRedditLabelColor]
            let selfTextAttr = [NSForegroundColorAttributeName : MyRedditSelfTextLabelColor]
            let fontAttr = [NSFontAttributeName : MyRedditSelfTextFont]
            parsedString.addAttributes(selfTextAttr, range: NSMakeRange(0, parsedString.string.characters.count))
            parsedString.addAttributes(titleAttr, range: NSMakeRange(0, link.title.characters.count))
            parsedString.addAttributes(fontAttr, range: NSMakeRange(0, parsedString.string.characters.count))
            
            self.bodyLabel.attributedText = parsedString

            self.addLinks()

            // Info            
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

            let indentPoints: CGFloat = CGFloat(self.indentationLevel) * self.indentationWidth
            self.leadingCommentLabelConstraint.constant = indentPoints
            self.leadinginfoLabelConstraint.constant = indentPoints

            self.contentView.backgroundColor = MyRedditBackgroundColor
            self.bodyLabel.backgroundColor = MyRedditBackgroundColor
            self.infoLabel.backgroundColor = MyRedditBackgroundColor
            self.contentView.backgroundColor = MyRedditBackgroundColor
            
            self.contentView.addBorder(edges: .Bottom, colour: MyRedditDarkBackgroundColor, thickness: 1)
        }
    }
    
    func configueForComment(comment comment: RKComment, isLinkAuthor: Bool) {
        self.comment = comment
        
        let body = comment.body.stringByReplacingOccurrencesOfString("&gt;",
            withString: ">",
            options: .CaseInsensitiveSearch,
            range: nil).stringByReplacingOccurrencesOfString("&amp;",
                withString: "&",
                options: .CaseInsensitiveSearch,
                range: nil)
                
        let parsedString = NSMutableAttributedString(attributedString: self.commentParser.attributedStringFromMarkdownString("\(body)"))
        parsedString.addAttribute(NSForegroundColorAttributeName,
            value: MyRedditLabelColor,
            range: NSMakeRange(0, parsedString.string.characters.count))
        parsedString.addAttribute(NSFontAttributeName,
            value: UIFont(name: MyRedditCommentInfoMediumFont.fontName, size: SettingsManager.defaultManager.commentFontSizeForDefaultTextSize)!,
            range: NSMakeRange(0, parsedString.string.characters.count))
        
        if parsedString.string.localizedCaseInsensitiveContainsString(">") {
            do {
                let regex = try NSRegularExpression(pattern: ">(.*)", options: .CaseInsensitive)
                regex.enumerateMatchesInString(parsedString.string,
                    options: .WithTransparentBounds,
                    range: NSMakeRange(0, parsedString.string.characters.count),
                    usingBlock: { (result, flags, error) -> Void in
                        if let foundRange = result?.range {
                            parsedString.addAttribute(NSForegroundColorAttributeName,
                                value: UIColor.lightGrayColor(),
                                range: foundRange)
                        }
                })
            } catch {}
        }
        
        self.bodyLabel.attributedText = parsedString

        self.addLinks()

        let timeAgo = self.comment.created.timeAgoSinceNow()
        
        var replies = "replies"
        
        if self.comment.replies.count == 1 {
            replies = "reply"
        }
        
        let info = "\(comment.author) - \(timeAgo) - \(self.comment.replies.count) \(replies)"
       
        if isLinkAuthor {
            let infoString = NSMutableAttributedString(string: info)
            let attrs = [NSForegroundColorAttributeName : isLinkAuthor ? MyRedditColor : MyRedditLabelColor,
                NSFontAttributeName : MyRedditCommentInfoMediumFont]
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
        
        let indentPoints: CGFloat = CGFloat(self.indentationLevel) * self.indentationWidth
        self.leadingCommentLabelConstraint.constant = indentPoints
        self.leadinginfoLabelConstraint.constant = indentPoints
        
        self.contentView.backgroundColor = MyRedditBackgroundColor
        self.bodyLabel.backgroundColor = MyRedditBackgroundColor
        self.infoLabel.backgroundColor = MyRedditBackgroundColor
        self.contentView.backgroundColor = MyRedditBackgroundColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        self.bodyLabel.text = nil

        for v in self.contentView.subviews {
            if v.tag == 123 {
                v.removeFromSuperview()
                break
            }
        }
    }
    
    func swipeCell(cell: SwipeCell, didTriggerSwipeWithType swipeType: SwipeType) {
        switch swipeType {
        case .LongRight: self.commentDelegate?.commentCell?(self,
            didLongRightSwipeForItem: self.link == nil ? self.comment : self.link)
        case .LongLeft: self.commentDelegate?.commentCell?(self,
            didLongLeftSwipeForItem: self.link == nil ? self.comment : self.link)
        case .ShortRight: self.commentDelegate?.commentCell?(self,
            didShortRightSwipeForItem: self.link == nil ? self.comment : self.link)
        default: self.commentDelegate?.commentCell?(self,
            didShortLeftSwipeForItem: self.link == nil ? self.comment : self.link)
        }
    }
}
