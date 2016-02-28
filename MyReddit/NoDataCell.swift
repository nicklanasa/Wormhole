//
//  NoDataCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 02-27-2016.
//  Copyright © 2015 MyReddit, Inc. All rights reserved.
//

import UIKit

class NoDataCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleLabel.font = UIFont(name: MyRedditTitleFont.fontName,
                                         size: SettingsManager.defaultManager.titleFontSizeForDefaultTextSize)
        
        self.titleLabel.textColor = MyRedditLabelColor
        self.contentView.backgroundColor = MyRedditBackgroundColor
        self.selectionStyle = .None
    }
}
