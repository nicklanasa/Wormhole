//
//  UILabel+Helpers.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/7/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension UILabel {
    func resizeHeightToFit(heightConstraint: NSLayoutConstraint) {
        let attributes = [NSFontAttributeName : font]
        numberOfLines = 0
        lineBreakMode = NSLineBreakMode.ByWordWrapping
        let rect = text!.boundingRectWithSize(CGSizeMake(frame.size.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        heightConstraint.constant = rect.height
        setNeedsLayout()
    }
    
    func heightText() -> CGFloat {
        let label: UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.size.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height + 20
    }
}