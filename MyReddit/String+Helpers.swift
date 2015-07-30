//
//  String+Helpers.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/26/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension String {
    func decode() -> String {
        let encodedData = self.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        let attributedString = NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil, error: nil)
        return attributedString!.string
    }
    
    func hasExtension() -> Bool {
        if self.rangeOfString(".jpg") != nil || self.rangeOfString(".png") != nil || self.rangeOfString(".gif") != nil || self.rangeOfString(".jpeg") != nil {
            return true
        }
        
        return false
    }
    
    var html2AttributedString: NSAttributedString {
        return NSAttributedString(data: dataUsingEncoding(NSUTF8StringEncoding)!,
            options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding],
            documentAttributes: nil,
            error: nil)!
    }

}
