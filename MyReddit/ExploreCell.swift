//
//  ExploreCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 7/31/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

enum ExploreCellType: Int {
    case Discover
    case Manual
    case FindUser
    case MyReddit
}

class ExploreCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    
    func configureWithType(type: ExploreCellType) {
        switch type {
        case .Discover:
            self.accessoryType = .DisclosureIndicator
            self.contentLabel.text = "discover subreddits"
        case .Manual:
            self.contentLabel.text = "manually enter subreddit"
            self.accessoryType = .None
        case .FindUser:
            self.contentLabel.text = "find user"
            self.accessoryType = .None
        case .MyReddit:
            self.contentLabel.text = "myreddit subreddit"
            self.accessoryType = .None
        default: break
        }
        
        self.contentLabel.textColor = MyRedditLabelColor
    }
}
