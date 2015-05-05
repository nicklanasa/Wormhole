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
    
    @IBOutlet weak var subredditTextField: UITextField!
    @IBOutlet weak var addbutton: UIButton!
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        self.delegate?.postSubredditCell(self, didTapAddButton: sender)
    }
}