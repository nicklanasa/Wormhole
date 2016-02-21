//
//  SettingsManager.swift
//  Muz
//
//  Created by Nick Lanasa on 12/23/14.
//  Copyright (c) 2014 Nytek Productions. All rights reserved.
//

import Foundation
import UIKit

enum Setting: NSInteger {
    case Flair
    case NSFW
    case SubredditLogos
    case NightMode
    case InfiniteScrolling
    case FullWidthImages
    case DefaultToReaderMode
}

enum TextSizeSetting: NSInteger {
    case Small
    case Medium
    case Large
}

enum TextSizeType {
    case Comment
    case Post
}

let _defaultManager = SettingsManager()

class SettingsManager {
    
    class var defaultManager : SettingsManager {
        return _defaultManager
    }
    
    func valueForSetting(setting: Setting) -> Bool {
        switch setting {
        case .Flair:
            if let flair = NSUserDefaults.standardUserDefaults().objectForKey("Flair") as? NSNumber {
                return flair.boolValue
            }
            
            return false
        case .NSFW:
            if let nsfw = NSUserDefaults.standardUserDefaults().objectForKey("NSFW") as? NSNumber {
                return nsfw.boolValue
            }
            
            return false
            
        case .SubredditLogos:
            if let logos = NSUserDefaults.standardUserDefaults().objectForKey("SubredditLogos") as? NSNumber {
                return logos.boolValue
            }
            
            return false
            
        case .NightMode:
            if let nightMode = NSUserDefaults.standardUserDefaults().objectForKey("NightMode") as? NSNumber {
                return nightMode.boolValue
            }
            
            return false
            
        case .FullWidthImages:
            if let fullWidthMode = NSUserDefaults.standardUserDefaults().objectForKey("FullWidthImages") as? NSNumber {
                return fullWidthMode.boolValue
            }
            
            return false
            
        case .InfiniteScrolling:
            if let scrolling = NSUserDefaults.standardUserDefaults().objectForKey("InfiniteScrolling") as? NSNumber {
                return scrolling.boolValue
            }
            
            return false
            
        case .DefaultToReaderMode:
            if let scrolling = NSUserDefaults.standardUserDefaults().objectForKey("DefaultToReaderMode") as? NSNumber {
                return scrolling.boolValue
            }
            
            return false
        }
    }
    
    func valueForTextSizeSetting(setting: TextSizeSetting) -> String {
        switch setting {
        case .Small:
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("TextSize") as? String {
                LocalyticsSession.shared().tagEvent("Small text toggled")
                return textSize
            }
            
            return "small"
        case .Medium:
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("TextSize") as? String {
                LocalyticsSession.shared().tagEvent("Medium text toggled")
                return textSize
            }
            
            return "medium"
            
        case .Large:
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("TextSize") as? String {
                LocalyticsSession.shared().tagEvent("Large text toggled")
                return textSize
            }
            
            return "large"
        }
    }
    
    func valueForCommentTextSizeSetting(setting: TextSizeSetting) -> String {
        switch setting {
        case .Small:
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("CommentTextSize") as? String {
                LocalyticsSession.shared().tagEvent("Small comment text toggled")
                return textSize
            }
            
            return "small"
        case .Medium:
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("CommentTextSize") as? String {
                LocalyticsSession.shared().tagEvent("Medium comment text toggled")
                return textSize
            }
            
            return "medium"
            
        case .Large:
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("CommentTextSize") as? String {
                LocalyticsSession.shared().tagEvent("Large comment text toggled")
                return textSize
            }
            
            return "large"
        }
    }
    
    func updateValueForSetting(setting: Setting, value: NSNumber) {
        switch setting {
        case .Flair:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "Flair")
            LocalyticsSession.shared().tagEvent("Flair toggled")
        case .NSFW:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "NSFW")
            LocalyticsSession.shared().tagEvent("NSFW toggled")
        case .SubredditLogos:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "SubredditLogos")
            LocalyticsSession.shared().tagEvent("Subreddit logos toggled")
        case .NightMode:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "NightMode")
            LocalyticsSession.shared().tagEvent("Night mode toggled")
        case .InfiniteScrolling:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "InfiniteScrolling")
            LocalyticsSession.shared().tagEvent("Infinite scrolling toggled")
        case .FullWidthImages:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "FullWidthImages")
            LocalyticsSession.shared().tagEvent("Full Width Images mode toggled")
        case .DefaultToReaderMode:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "DefaultToReaderMode")
            LocalyticsSession.shared().tagEvent("Full Width Images mode toggled")
        }
    }
    
    func updateValueForTextSizeType(type: TextSizeType, setting: TextSizeSetting) {
        switch type {
        case .Comment: self.updateValueForCommentTextSizeSetting(setting)
        default: self.updateValueForTextSizeSetting(setting)
        }
    }
    
    private func updateValueForTextSizeSetting(setting: TextSizeSetting) {
        switch setting {
        case .Small:
            NSUserDefaults.standardUserDefaults().setObject("small", forKey: "TextSize")
        case .Medium:
            NSUserDefaults.standardUserDefaults().setObject("medium", forKey: "TextSize")
        case .Large:
            NSUserDefaults.standardUserDefaults().setObject("large", forKey: "TextSize")
        }
    }
    
    private func updateValueForCommentTextSizeSetting(setting: TextSizeSetting) {
        switch setting {
        case .Small:
            NSUserDefaults.standardUserDefaults().setObject("small", forKey: "CommentTextSize")
        case .Medium:
            NSUserDefaults.standardUserDefaults().setObject("medium", forKey: "CommentTextSize")
        case .Large:
            NSUserDefaults.standardUserDefaults().setObject("large", forKey: "CommentTextSize")
        }
    }
    
    var defaultTextSize: TextSizeSetting! {
        get {
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("TextSize") as? String {
                switch textSize {
                case "small": return .Small
                case "large": return .Large
                default: return .Medium
                }
            }
            
            return .Medium
        }
    }
    
    var defaultCommentTextSize: TextSizeSetting! {
        get {
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("CommentTextSize") as? String {
                switch textSize {
                case "small": return .Small
                case "large": return .Large
                default: return .Medium
                }
            }
            
            return .Medium
        }
    }
    
    var titleFontSizeForDefaultTextSize: CGFloat! {
        get {
            switch self.defaultTextSize.rawValue {
            case TextSizeSetting.Small.rawValue: return 14.0
            case TextSizeSetting.Large.rawValue: return 18.0
            default: return 16.0
            }
        }
    }
    
    var commentFontSizeForDefaultTextSize: CGFloat! {
        get {
            switch self.defaultCommentTextSize.rawValue {
            case TextSizeSetting.Small.rawValue: return 12.0
            case TextSizeSetting.Large.rawValue: return 14.0
            default: return 16.0
            }
        }
    }
    
    var purchased: Bool! {
        get {
            if NSUserDefaults.standardUserDefaults().objectForKey("purchased") == nil {
                return false
            } else {
                if let purchaseDate = NSUserDefaults.standardUserDefaults().objectForKey("expirationDate") as? NSDate {
                    return NSDate().compare(purchaseDate) == .OrderedAscending
                } else {
                    return true
                }
            }
        }
    }
    
    var productID: String! {
        get {
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                return "myreddit.premium.ipad"
            } else {
                return "myreddit.premium"
            }
        }
    }
}
