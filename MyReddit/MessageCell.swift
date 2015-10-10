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
        
        self.imageSet = SwipeCellImageSetMake(UIImage(named: "moreWhite"), UIImage(named: "moreWhite"), UIImage(named: "Reply"), UIImage(named: "Reply"))
        self.colorSet = SwipeCellColorSetMake(MyRedditColor, MyRedditColor, MyRedditReplyColor, MyRedditReplyColor)
        
        self.bodyTextView.delegate = self
        
        self.icon.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    var message: RKMessage! {
        didSet {
            
            self.titleLabel.text = message.subject.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: .CaseInsensitiveSearch, range: nil)
            
            let parser = XNGMarkdownParser()
            parser.paragraphFont = MyRedditSelfTextFont
            parser.boldFontName = MyRedditCommentTextBoldFont.familyName
            parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
            parser.italicFontName = MyRedditCommentTextItalicFont.familyName
            parser.linkFontName = MyRedditCommentTextBoldFont.familyName
            
            let parsedString = NSMutableAttributedString(attributedString: parser.attributedStringFromMarkdownString(message.messageBody.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: .CaseInsensitiveSearch, range: nil)))
            let selfTextAttr = [NSForegroundColorAttributeName : UIColor.darkGrayColor()]
            parsedString.addAttributes(selfTextAttr, range: NSMakeRange(0, parsedString.string.characters.count))
            
            self.bodyTextView.attributedText = parsedString
            
            let infoString = NSMutableAttributedString(string:"\(message.created.timeAgoSinceNow()) | \(message.author)")
            let attrs = [NSForegroundColorAttributeName : MyRedditColor]
            infoString.addAttributes(attrs, range: NSMakeRange(0, message.created.timeAgoSinceNow().characters.count))
            
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