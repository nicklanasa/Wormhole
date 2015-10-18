//
//  PostTitleCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/5/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class PostTitleCell: UITableViewCell {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    override func awakeFromNib() {
        self.updateAppearance()
    }
    
    private func updateAppearance() {
        self.titleTextField.attributedPlaceholder = NSAttributedString(string: "enter title...",
            attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        self.titleTextField.textColor = MyRedditLabelColor
        self.backgroundColor = MyRedditBackgroundColor
    }
    
    override func prepareForReuse() {
        self.updateAppearance()
    }
}