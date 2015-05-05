//
//  MessageCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/26/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol MessageCellDelegate {
    func messageCell(cell: MessageCell, didTapLink link: NSURL)
}

class MessageCell: JZSwipeCell, UITextViewDelegate {
    
    var messageCellDelegate: MessageCellDelegate?
    
    var currentTappedURL: NSURL! {
        didSet {
            self.messageCellDelegate?.messageCell(self, didTapLink: self.currentTappedURL)
        }
    }
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageSet = SwipeCellImageSetMake(UIImage(named: "moreWhite"), UIImage(named: "moreWhite"), UIImage(named: "ReplySmall"), UIImage(named: "ReplySmall"))
        self.colorSet = SwipeCellColorSetMake(MyRedditColor, MyRedditColor, MyRedditReplyColor, MyRedditReplyColor)
        
        self.bodyTextView.delegate = self
    }
    
    var message: RKMessage! {
        didSet {
            
            if !message.unread.boolValue {
                self.readLabel.hidden = true
            }
            
            self.titleLabel.text = message.subject
            
            var parser = XNGMarkdownParser()
            parser.paragraphFont = MyRedditSelfTextFont
            parser.boldFontName = MyRedditCommentTextBoldFont.familyName
            parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
            parser.italicFontName = MyRedditCommentTextItalicFont.familyName
            parser.linkFontName = MyRedditCommentTextBoldFont.familyName
            
            var parsedString = NSMutableAttributedString(attributedString: parser.attributedStringFromMarkdownString(message.messageBody))
            var titleAttr = [NSForegroundColorAttributeName : MyRedditLabelColor]
            var selfTextAttr = [NSForegroundColorAttributeName : UIColor.darkGrayColor()]
            parsedString.addAttributes(selfTextAttr, range: NSMakeRange(0, count(parsedString.string)))
            
            self.bodyTextView.attributedText = parsedString
            
            var infoString = NSMutableAttributedString(string:"\(message.created.timeAgo()) | \(message.author)")
            var attrs = [NSForegroundColorAttributeName : MyRedditColor]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(message.created.timeAgo())))
            
            self.infoLabel.attributedText = infoString
            
            self.titleLabel.textColor = MyRedditLabelColor
            self.bodyTextView.textColor = SettingsManager.defaultManager.valueForSetting(.NightMode) ? UIColor.whiteColor() : UIColor.darkGrayColor()
            self.bodyTextView.backgroundColor = MyRedditBackgroundColor
            
            self.contentView.backgroundColor = MyRedditBackgroundColor
        }
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        self.currentTappedURL = URL
        
        return false
    }
}