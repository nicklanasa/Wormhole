//
//  RKLink+Viewed.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/5/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension RKLink {
    func viewed() -> Bool {
        if let _: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(self.identifier) {
            return true
        } else {
            return false
        }
    }
    
    func saved() -> Bool {
        if let _: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(self.identifier + "saved") {
            return true
        } else {
            return false
        }
    }
    
    func saveLink() {
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: self.identifier + "saved")
    }
    
    func unSaveLink() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: self.identifier + "saved")
    }
    
    func isHidden() -> Bool {
        if let _: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(self.identifier + "hidden") {
            return true
        } else {
            if self.hidden {
                return true
            }
            return false
        }
    }
    
    func hideLink() {
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: self.identifier + "hidden")
    }
    
    func unHideLink() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: self.identifier + "hidden")
    }
    
    func urlForLink() -> String? {
        if self.isImageLink() {
            return self.URL.absoluteString
        } else if self.media != nil {
            if let thumbnailURL = self.media.thumbnailURL {
                return thumbnailURL.description
            }
        } else if (self.domain == "imgur.com" && !self.domain.containsString("gallery")) {
            return self.URL.absoluteString + ".jpg"
        }
        
        return nil
    }
    
    func hasImage() -> Bool {
        return self.isImageLink() || (self.domain == "imgur.com" && !self.URL.absoluteString.containsString("gallery")) || self.media != nil
    }
    
    func isImgAlbum() -> Bool {
        return (self.domain == "imgur.com" && self.URL.absoluteString.componentsSeparatedByString("/").count > 4)
    }
    
    func isImageOrGifLink() -> Bool {
        let supportedFileTypeSuffixes = NSSet(array: ["tiff", "tif", "jpg", "jpeg", "png"])
        
        
        if let urlExtension = self.URL.pathExtension {
            return supportedFileTypeSuffixes.containsObject(urlExtension)
        }
        
        return false
    }
    
    func isGifLink() -> Bool {
        if self.URL.absoluteString.containsString("gif") || self.URL.absoluteString.containsString("gifv") {
            return true
        }
        
        return false
    }
    
    func gifLink() -> NSURL {
        if self.URL.absoluteString.containsString("gifv") {
            if let url = NSURL(string: self.URL.absoluteString.stringByReplacingOccurrencesOfString("gifv", withString: "gif")) {
                return url
            }
        }
        
        return self.URL
    }

    func unsave(completion: (error: NSError?) -> ()) {
        LocalyticsSession.shared().tagEvent("Unsave")
        RedditSession.sharedSession.unSaveLink(
            self,
            completion: { (error) -> () in
                self.saveLink()
            })
    }

    func save(completion: (error: NSError?) -> ()) {
        LocalyticsSession.shared().tagEvent("Save")
        RedditSession.sharedSession.saveLink(
            self,
            completion: { (error) -> () in
                self.saveLink()
            })
    }

    func unhide(completion: (error: NSError?) -> ()) {
        LocalyticsSession.shared().tagEvent("unhide")
        RedditSession.sharedSession.unHideLink(
            self,
            completion: { (error) -> () in
                self.unHideLink()
            })
    }

    func hide(completion: (error: NSError?) -> ()) {
        LocalyticsSession.shared().tagEvent("unhide")
        RedditSession.sharedSession.unHideLink(
            self,
            completion: { (error) -> () in
                self.hideLink()
            })
    }
}
