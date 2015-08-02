//
//  UIAlert+Helpers.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 7/31/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

extension UIAlertView {
    
    // Errors
    
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
    
    class func showUnableToUnsubscribeError() {
        UIAlertView(title: "Error!",
            message: "Unable to unsubscribe to Subreddit. Please make sure you are connected to the internets.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showSubscribeError() {
        UIAlertView(title: "Error!",
            message: "Unable to subscribe to Subreddit. Please make sure you are connected to the internets.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showUnableToReportCommentError() {
        UIAlertView(title: "Error!",
            message: "Unable to report comment. Please make sure you are connected to the internets.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showUnableToDeleteCommentError() {
        UIAlertView(title: "Error!",
            message: "Unable to delete comment. Please make sure you are connected to the internets.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showUnableToDeleteLinkError() {
        UIAlertView(title: "Error!",
            message: "Unable to link comment. Please make sure you are connected to the internets.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showUnableToEditCommentError() {
        UIAlertView(title: "Error!",
            message: "Unable to edit comment. Please make sure you are connected to the internets.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showUnableToAddCommentError() {
        UIAlertView(title: "Error!",
            message: "Unable to add comment. Please make sure you are connected to the internets.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showUnableToReplyCommentError() {
        UIAlertView(title: "Error!",
            message: "Unable to reply to comment. Please make sure you are connected to the internets.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showUnableToSaveCommentError() {
        UIAlertView(title: "Error!",
            message: "Unable to save comment. Please make sure you are connected to the internets.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    // Success
    
    class func showReportCommentSuccess() {
        UIAlertView(title: "Success!",
            message: "Comment reported!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showDeleteLinkSuccess() {
        UIAlertView(title: "Success!",
            message: "Comment deleted!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showDeleteCommentSuccess() {
        UIAlertView(title: "Success!",
            message: "Link deleted!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showAddedCommentSuccess() {
        UIAlertView(title: "Success!",
            message: "Comment added!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }

    class func showReplyCommentSuccess() {
        UIAlertView(title: "Success!",
            message: "Reply added!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showEditedCommentSuccess() {
        UIAlertView(title: "Success!",
            message: "Comment edited!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    class func showSaveCommentSuccess() {
        UIAlertView(title: "Success!",
            message: "Comment saved!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
}
