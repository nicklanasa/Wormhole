//
//  NSString+Helpers.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/16/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension String {
    init(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        
        var attributedString = NSAttributedString(string: "")
        
        do {
            attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch {}
        
        self.init(attributedString.string)
    }
}