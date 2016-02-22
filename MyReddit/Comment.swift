//
//  Comment.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 2/21/16.
//  Copyright © 2016 Nytek Production. All rights reserved.
//

import Foundation

class Comment: NSObject {
    
    var rkComment: RKComment!
    
    var markdown = Markdown()
    
    var attributedBody: NSAttributedString!
    
    convenience init(rkComment: RKComment) {
        self.init()
        self.rkComment = rkComment
        
        self.setup()
    }
    
    private func setup() {
        let html = self.markdown.transform(self.rkComment.body)
        
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
           
            self.attributedBody = attributedText
        } catch { }
    }
}