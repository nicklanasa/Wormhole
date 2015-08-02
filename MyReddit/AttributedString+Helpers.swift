//
//  AttributedString+Helpers.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 8/1/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    func layout() {
        self.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, self.length), options: NSAttributedStringEnumerationOptions(0)) { (value, range, stop) -> Void in
            if let attachement = value as? NSTextAttachment {
                let image = attachement.imageForBounds(attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location)
                let screenSize: CGRect = UIScreen.mainScreen().bounds
                if image.size.width > screenSize.width-2 {
                    let newImage = image.resize(CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width - 50))
                    let newAttribut = NSTextAttachment()
                    newAttribut.image = newImage
                    self.addAttribute(NSAttachmentAttributeName, value: newAttribut, range: range)
                }
            }
        }
    }
}