//
//  SettingsManager.swift
//  Muz
//
//  Created by Nick Lanasa on 12/23/14.
//  Copyright (c) 2014 Nytek Productions. All rights reserved.
//

import Foundation

enum Setting: NSInteger {
    case Flair
    case NSFW
    case SubredditLogos
    case NightMode
    case InfiniteScrolling
}

enum TextSizeSetting: NSInteger {
    case Small
    case Medium
    case Large
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
            
        case .InfiniteScrolling:
            if let scrolling = NSUserDefaults.standardUserDefaults().objectForKey("InfiniteScrolling") as? NSNumber {
                return scrolling.boolValue
            }
            
            return false
            
        default: return false
            
        }
    }
    
    func valueForTextSizeSetting(setting: TextSizeSetting) -> String {
        switch setting {
        case .Small:
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("TextSize") as? String {
                return textSize
            }
            
            return "Medium"
        case .Medium:
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("TextSize") as? String {
                return textSize
            }
            
            return "Medium"
            
        case .Large:
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("TextSize") as? String {
                return textSize
            }
            
            return "Medium"
            
        default: return "Medium"
            
        }
    }
    
    func updateValueForSetting(setting: Setting, value: NSNumber) {
        switch setting {
        case .Flair:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "Flair")
        case .NSFW:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "NSFW")
        case .SubredditLogos:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "SubredditLogos")
        case .NightMode:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "NightMode")
        case .InfiniteScrolling:
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "InfiniteScrolling")
        default: break
            
        }
    }
    
    func updateValueForTextSizeSetting(setting: TextSizeSetting) {
        switch setting {
        case .Small:
            NSUserDefaults.standardUserDefaults().setObject("Small", forKey: "TextSize")
        case .Medium:
            NSUserDefaults.standardUserDefaults().setObject("Medium", forKey: "TextSize")
        case .Large:
            NSUserDefaults.standardUserDefaults().setObject("Large", forKey: "TextSize")
        default: break
            
        }
    }
    
    var defaultTextSize: TextSizeSetting! {
        get {
            if let textSize = NSUserDefaults.standardUserDefaults().objectForKey("TextSize") as? String {
                switch textSize {
                case "Small": return .Small
                case "Large": return .Large
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
            case TextSizeSetting.Large.rawValue: return 19.0
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
}
