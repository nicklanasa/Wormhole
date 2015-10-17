//
//  PostSubredditCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/5/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol PostSubredditCellDelegate {
    func postSubredditCell(cell: PostSubredditCell, didTapAddButton sender: AnyObject)
}

class PostSubredditCell: UITableViewCell {
    
    var delegate: PostSubredditCellDelegate?
    
    override func awakeFromNib() {
        self.subredditTextField.attributedPlaceholder = NSAttributedString(string: "enter subreddit...",
            attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        
        if SettingsManager.defaultManager.valueForSetting(.NightMode) {
            let image = UIImage(named: "CircleAddWhite")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            self.addbutton.setImage(image, forState: .Normal)
        } else {
            let image = UIImage(named: "CircleAdd")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            self.addbutton.setImage(image, forState: .Normal)
        }
        
        self.subredditTextField.textColor = MyRedditLabelColor
    }
    
    @IBOutlet weak var subredditTextField: UITextField!
    @IBOutlet weak var addbutton: UIButton!
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        self.delegate?.postSubredditCell(self, didTapAddButton: sender)
    }
}