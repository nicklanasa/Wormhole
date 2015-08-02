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
        
        for var i = 1; i < self.indentationLevel; i++ {
            var lineView = UIView(frame: CGRectMake(CGFloat(i * 15), 5, 1, self.frame.size.height - 5))
            lineView.backgroundColor = MyRedditCommentLinesColor
            self.lines.append(lineView)
            self.contentView.addSubview(lineView)
        }
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
        var replyImage = UIImage(named: "moreWhite")?.imageWithRenderingMode(.AlwaysOriginal)
        
        self.imageSet = SwipeCellImageSetMake(downVoteImage, downVoteImage, upVoteImage, replyImage)
        self.colorSet = SwipeCellColorSetMake(MyRedditDownvoteColor, MyRedditDownvoteColor, MyRedditUpvoteColor, MyRedditReplyColor)
        
        self.commentTextView.delegate = self
        
        self.backgroundView?.backgroundColor = MyRedditBackgroundColor
        self.defaultBackgroundColor = MyRedditBackgroundColor
        self.commentTextView.textColor = MyRedditLabelColor
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
            
            var title = link.title.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: nil, range: nil)
            
            var parsedString = NSMutableAttributedString(string: "\(title)\(selfText)")
            var titleAttr = [NSForegroundColorAttributeName : MyRedditLabelColor]
            var selfTextAttr = [NSForegroundColorAttributeName : MyRedditSelfTextLabelColor]
            var fontAttr = [NSFontAttributeName : MyRedditSelfTextFont]
            parsedString.addAttributes(selfTextAttr, range: NSMakeRange(0, count(parsedString.string)))
            parsedString.addAttributes(titleAttr, range: NSMakeRange(0, count(link.title)))
            parsedString.addAttributes(fontAttr, range: NSMakeRange(0, count(parsedString.string)))
            self.commentTextView.attributedText = parsedString
            
            var timeAgo = link.created.timeAgoSimple()
            
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
            
            self.commentTextView.backgroundColor = MyRedditBackgroundColor
            self.contentView.backgroundColor = MyRedditBackgroundColor
            
            self.leadingTextViewConstraint.constant = 15
            self.leadinginfoLabelConstraint.constant = 15
        }
    }
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var comment: RKComment!
    
    func configueForComment(#comment: RKComment, isLinkAuthor: Bool) {
        
        self.comment = comment
        let body = comment.body.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: nil, range: nil).stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: nil, range: nil)
        self.commentTextView.text = body
        
        var timeAgo = self.comment.created.timeAgoSimple()
        
        var info = "\(comment.author) - \(timeAgo)"
       
        if isLinkAuthor {
            var infoString = NSMutableAttributedString(string: info)
            var attrs = [NSForegroundColorAttributeName : isLinkAuthor ? MyRedditColor : MyRedditLabelColor, NSFontAttributeName : MyRedditCommentInfoMediumFont]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(comment.author)))
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
    
        self.commentTextView.textColor = MyRedditLabelColor
        self.commentTextView.font = MyRedditCommentTextFont
        self.commentTextView.backgroundColor = MyRedditBackgroundColor
        self.contentView.backgroundColor = MyRedditBackgroundColor
        self.infoLabel.backgroundColor = MyRedditBackgroundColor
        
        var indentPoints: CGFloat = CGFloat(self.indentationLevel) * self.indentationWidth
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
        self.backgroundView?.backgroundColor = MyRedditBackgroundColor
        self.indentationLevel = 0
        self.indentationWidth = 0
        self.separatorInset = UIEdgeInsetsZero
    }
}