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
        
        var scaledImageRect = CGRectZero
        
        var aspectWidth = toSize.width / self.size.width
        //var aspectHeight = toSize.height / self.size.height
        //var aspectRatio = min(aspectWidth, aspectHeight)
        
        var aspectRatio = aspectWidth
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        
        scaledImageRect.origin.x = (toSize.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (toSize.height - scaledImageRect.size.height) / 2
        
        UIGraphicsBeginImageContextWithOptions(toSize, false, 0)
        self.drawInRect(scaledImageRect)
        var scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
