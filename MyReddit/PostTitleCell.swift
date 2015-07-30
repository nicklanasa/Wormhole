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
        self.titleTextField.attributedPlaceholder = NSAttributedString(string: "enter title...",
            attributes: [NSForegroundColorAttributeName : MyRedditPostTitleTextLabelColor])
        self.titleTextField.textColor = MyRedditLabelColor
    }
}