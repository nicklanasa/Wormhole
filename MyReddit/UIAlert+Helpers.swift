//
//  UIAlert+Helpers.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 7/31/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

extension UIAlertView {
    
    class func showPostNoSubredditError() {
        UIAlertView(title: "Error!",
            message: "You must supply a subreddit!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showPostNoTitleError() {
        UIAlertView(title: "Error!",
            message: "You must supply a title!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showPostNoLinkOrImageError() {
        UIAlertView(title: "Error!",
            message: "You must supply a link or an image!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showPostNoTextError() {
        UIAlertView(title: "Error!",
            message: "You must supply text!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showErrorWithError(error: NSError?) {
        if error == nil {
            UIAlertView(title: "Error!",
                message: "Unable to complete request",
                delegate: self,
                cancelButtonTitle: "Ok").show()
        } else {
            UIAlertView(title: "Error!",
                message: error!.localizedDescription,
                delegate: self,
                cancelButtonTitle: "Ok").show()
        }
    }
}
