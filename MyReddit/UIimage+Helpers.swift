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
        
        let aspectWidth = toSize.width / self.size.width
        let aspectHeight = toSize.height / self.size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        
        scaledImageRect.origin.x = (toSize.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (toSize.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(toSize, false, 0)
        self.drawInRect(scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func imageWithImage(image: UIImage, toSize size: CGSize) -> UIImage? {
        var newHeight = image.size.height / image.size.width * size.width
        newHeight = (newHeight * self.scale) / self.scale
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, newHeight), false, self.scale)
        self.drawInRect(CGRectMake(0, 0, size.width, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
