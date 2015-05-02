//
//  SubredditCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class SubredditCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var nsfwLabel: UILabel!
    @IBOutlet weak var subredditImageView: UIImageView!

    var subreddit: Subreddit! {
        didSet {
            self.nameLabel.text = subreddit.name
            self.subscribersLabel.text = subreddit.totalSubscribers.integerValue.abbreviateNumber()
            
            self.nsfwLabel.hidden = true
            
            if subreddit.over18.boolValue {
                self.nsfwLabel.hidden = false
            }
            
            if let headerURL = subreddit.headerImageURL {
                self.subredditImageView.sd_setImageWithURL(NSURL(string: headerURL), placeholderImage: UIImage(named: "Reddit"))
            } else {
                self.subredditImageView.image = UIImage(named: "Reddit")
            }
        }
    }
    
    var rkSubreddit: RKSubreddit! {
        didSet {
            self.nameLabel.text = rkSubreddit.name.capitalizedString
            
            self.subscribersLabel.hidden = true
            
            self.nsfwLabel.hidden = true
            
            if rkSubreddit.over18.boolValue {
                self.nsfwLabel.hidden = false
            }
            
            if let headerURL = rkSubreddit.headerImageURL {
                self.subredditImageView.sd_setImageWithURL(headerURL, placeholderImage: UIImage(named: "Reddit"))
            } else {
                self.subredditImageView.image = UIImage(named: "Reddit")
            }
        }
    }
    
    var subredditData: [String : AnyObject]! {
        didSet {
            
            if let name = subredditData["title"] as? String {
                self.nameLabel.text = name
            } else {
                self.nameLabel.text = "Unknown"
            }
            
            self.subscribersLabel.hidden = true
            
            self.nsfwLabel.hidden = true
            
            if let over18 = subredditData["over18"] as? NSNumber {
                if over18.boolValue {
                    self.nsfwLabel.hidden = false
                }
            }
            
            if let headerIMG = subredditData["header_img"] as? String {
                if let headerURL = NSURL(string: headerIMG) {
                    self.subredditImageView.sd_setImageWithURL(headerURL, placeholderImage: UIImage(named: "Reddit"))
                } else {
                    self.subredditImageView.image = UIImage(named: "Reddit")
                }
            }
        }
    }
}