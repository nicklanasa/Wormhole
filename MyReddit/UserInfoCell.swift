//
//  UserInfoCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 4/30/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class UserInfoCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        self.titleLabel.textColor = MyRedditLabelColor
    }
    
    var user: RKUser! {
        didSet {
            self.titleLabel.text = user.username
            self.infoLabel.hidden = true
        }
    }
}