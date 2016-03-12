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
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            return attributedString.string
        } catch {
            return ""
        }
    }
    
    func hasExtension() -> Bool {
        if self.rangeOfString(".jpg") != nil || self.rangeOfString(".png") != nil || self.rangeOfString(".gif") != nil || self.rangeOfString(".jpeg") != nil {
            return true
        }
        
        return false
    }
    
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    var html2AttributedString: NSAttributedString {
        do {
            let str = try NSMutableAttributedString(data: dataUsingEncoding(NSUTF8StringEncoding)!,
                options:[NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding],
                documentAttributes: nil)
            
            str.layout()
            
            return str
        } catch {
            return NSAttributedString(string: "Unable to get content.")
        }
    }
}
