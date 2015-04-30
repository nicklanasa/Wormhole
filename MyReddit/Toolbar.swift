//
//  Toolbar.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/17/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class Toolbar: UIToolbar {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add transparency.
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0);
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor.blackColor().colorWithAlphaComponent(0.7).CGColor)
        CGContextFillRect(context, rect)
        let transparentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(transparentImage, forToolbarPosition: .Any, barMetrics: .Default)
    }
}
