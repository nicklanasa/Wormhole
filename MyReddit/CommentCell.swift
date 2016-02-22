//
//  CommentCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 4/27/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import MMMarkdown

@objc protocol CommentCellDelegate {
    func commentCell(cell: CommentCell, didTapLink link: NSURL)
    optional func commentCell(cell: CommentCell, didShortRightSwipeForItem item: AnyObject)
    optional func commentCell(cell: CommentCell, didLongRightSwipeForItem item: AnyObject)
    optional func commentCell(cell: CommentCell, didShortLeftSwipeForItem item: AnyObject)
    optional func commentCell(cell: CommentCell, didLongLeftSwipeForItem item: AnyObject)
}

class CommentCell: SwipeCell,
SwipeCellDelegate,
UITextViewDelegate {
    
    @IBOutlet weak var bottomTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadinginfoLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var commentDelegate: CommentCellDelegate?
        
    var currentTappedURL: NSURL! {
        didSet {
            self.commentDelegate?.commentCell(self,
                didTapLink: self.currentTappedURL)
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
        self.commentTextView.delegate = self
        
        self.commentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0)
        
        self.contentView.backgroundColor = MyRedditDarkBackgroundColor
        self.commentTextView.backgroundColor = MyRedditDarkBackgroundColor
        self.infoLabel.backgroundColor = MyRedditDarkBackgroundColor
        self.contentView.backgroundColor = MyRedditDarkBackgroundColor
    }
    
    var link: RKLink! {
        didSet {
            
            self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0)
            
            var commentTitle = ""
            
            var selfText = ""
            
            if link.selfPost && link.selfText.characters.count > 0 {
                selfText = "\n\n\(link.selfText)".stringByReplacingOccurrencesOfString("&gt;",
                    withString: ">",
                    options: .CaseInsensitiveSearch,
                    range: nil)
            }
            
            let title = link.title.stringByReplacingOccurrencesOfString("&gt;", withString: ">",
                options: .CaseInsensitiveSearch,
                range: nil)
            
            
            commentTitle = "\(title)\(selfText)"
            
            do {
                let html = try MMMarkdown.HTMLStringWithMarkdown(commentTitle.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
                let attributedText = try! NSMutableAttributedString(data: html.dataUsingEncoding(NSUTF8StringEncoding,
                    allowLossyConversion: false)!,
                    options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                    documentAttributes: nil)
                
                let titleAttr = [NSForegroundColorAttributeName : MyRedditLabelColor]
                let selfTextAttr = [NSForegroundColorAttributeName : MyRedditSelfTextLabelColor]
                let fontAttr = [NSFontAttributeName : MyRedditSelfTextFont]
                attributedText.addAttributes(selfTextAttr, range: NSMakeRange(0, attributedText.string.characters.count))
                attributedText.addAttributes(titleAttr, range: NSMakeRange(0, self.link.title.characters.count))
                attributedText.addAttributes(fontAttr, range: NSMakeRange(0, attributedText.string.characters.count))
                
                self.commentTextView.attributedText = attributedText
            } catch { }
            
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
            self.leadingTextViewConstraint.constant = indentPoints
            self.leadinginfoLabelConstraint.constant = indentPoints + 10
            
            self.contentView.backgroundColor = MyRedditBackgroundColor
            self.commentTextView.backgroundColor = MyRedditBackgroundColor
            self.infoLabel.backgroundColor = MyRedditBackgroundColor
            self.contentView.backgroundColor = MyRedditBackgroundColor
        }
    }
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var comment: RKComment!
    
    var markdown = Markdown()
    
    func configueForComment(comment comment: RKComment, isLinkAuthor: Bool) {
        
        self.comment = comment
        
        let html = self.markdown.transform(comment.body)
        
        do {
            let attributedText = try! NSMutableAttributedString(data: html.dataUsingEncoding(NSUTF8StringEncoding,
                allowLossyConversion: false)!,
                options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
            
            attributedText.addAttribute(NSForegroundColorAttributeName,
                value: MyRedditLabelColor,
                range: NSMakeRange(0, attributedText.string.characters.count))
            attributedText.addAttribute(NSFontAttributeName,
                value: UIFont(name: MyRedditCommentTextFont.fontName,
                    size: SettingsManager.defaultManager.commentFontSizeForDefaultTextSize)!,
                range: NSMakeRange(0, attributedText.string.characters.count))
            
            if attributedText.string.localizedCaseInsensitiveContainsString(">") {
                do {
                    let regex = try NSRegularExpression(pattern: ">(.*)", options: .CaseInsensitive)
                    regex.enumerateMatchesInString(attributedText.string,
                        options: .WithTransparentBounds,
                        range: NSMakeRange(0, attributedText.string.characters.count),
                        usingBlock: { (result, flags, error) -> Void in
                            if let foundRange = result?.range {
                                attributedText.addAttribute(NSForegroundColorAttributeName,
                                    value: UIColor.lightGrayColor(),
                                    range: foundRange)
                            }
                    })
                }
            }
            
            self.commentTextView.attributedText = attributedText
        } catch { }

        
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
        self.leadingTextViewConstraint.constant = indentPoints
        self.leadinginfoLabelConstraint.constant = indentPoints + 10
    }
    
    func textView(textView: UITextView,
        shouldInteractWithURL URL: NSURL,
        inRange characterRange: NSRange) -> Bool {
        self.currentTappedURL = URL
        return false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.indentationLevel = 0
        self.indentationWidth = 0
        
        self.contentView.backgroundColor = MyRedditDarkBackgroundColor
        self.commentTextView.backgroundColor = MyRedditDarkBackgroundColor
        self.infoLabel.backgroundColor = MyRedditDarkBackgroundColor
        self.contentView.backgroundColor = MyRedditDarkBackgroundColor
    }
    
    func swipeCell(cell: SwipeCell, didTriggerSwipeWithType swipeType: SwipeType) {
        switch swipeType {
        case .LongRight: self.commentDelegate?.commentCell?(self, didLongRightSwipeForItem: self.link == nil ? self.comment : self.link)
        case .LongLeft: self.commentDelegate?.commentCell?(self, didLongLeftSwipeForItem: self.link == nil ? self.comment : self.link)
        case .ShortRight: self.commentDelegate?.commentCell?(self, didShortRightSwipeForItem: self.link == nil ? self.comment : self.link)
        default: self.commentDelegate?.commentCell?(self, didShortLeftSwipeForItem: self.link == nil ? self.comment : self.link)
        }
    }
}
