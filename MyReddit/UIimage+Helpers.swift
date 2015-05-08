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
        let scale: CGFloat = 0.0
        UIGraphicsBeginImageContextWithOptions(toSize, true, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: toSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}
