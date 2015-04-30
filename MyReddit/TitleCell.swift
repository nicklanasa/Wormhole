//
//  TitleCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class TitleCell: PostCell {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var subredditLabel: UILabel!
    
    override var link: RKLink! {
        didSet {
            self.titleLabel.text = link.title
            self.scoreLabel.text = link.score.description
            self.commentsLabel.text = link.totalComments.description
            self.subredditLabel.text = "/r/\(link.subreddit)"
            
            var infoString = NSMutableAttributedString(string: "\(link.domain) | \(link.author)")
            var attrs = [NSForegroundColorAttributeName : UIColor.blackColor()]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(link.domain)))
            
            self.postInfoLabel.attributedText = infoString
        }
    }
    
}