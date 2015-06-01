//
//  UIimage+Helpers.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/8/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension UIImage {
    func resize(toSize: CGSize) -> UIImage {
        let scale = toSize.height / self.size.height
        let newWidth = self.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, toSize.height))
        self.drawInRect(CGRectMake(0, 0, newWidth, toSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
