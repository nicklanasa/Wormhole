//
//  NavBarController.swift
//  Muz
//
//  Created by Nick Lanasa on 12/9/14.
//  Copyright (c) 2014 Nytek Productions. All rights reserved.
//

import Foundation
import UIKit

class NavBarController: UINavigationController {
    override func viewDidLoad() {
        // Add transparency.
//        let rect = CGRectMake(0, 0, 1, 1)
//        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0);
//        let context = UIGraphicsGetCurrentContext()
//        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
//        CGContextFillRect(context, rect)
//        let transparentImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
        self.navigationBar.translucent = false
        self.navigationBar.tintColor = MyRedditLabelColor
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: MyRedditTitleFont,
            NSForegroundColorAttributeName: MyRedditLabelColor]
    }
}
