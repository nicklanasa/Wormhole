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

    var subreddit: Subreddit! {
        didSet {
            self.nameLabel.text = subreddit.name
            self.subscribersLabel.text = subreddit.totalSubscribers.integerValue.abbreviateNumber()
            
            self.nsfwLabel.hidden = true
            
            if subreddit.over18.boolValue {
                self.nsfwLabel.hidden = false
            }
        }
    }
}