//
//  EmailCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/30/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol EmailCellDelegate {
    func emailCell(cell: EmailCell, didTapReturnButton sender: AnyObject)
}

class EmailCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: EmailCellDelegate?
    
    var user: RKUser! {
        didSet {
            self.usernameTextField.text = user.username
        }
    }
    
    override func awakeFromNib() {
        self.usernameTextField.delegate = self
        self.usernameLabel.textColor = MyRedditLabelColor
        self.usernameTextField.textColor = MyRedditLabelColor
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "enter username...",
            attributes: [NSForegroundColorAttributeName : MyRedditSelfTextLabelColor])
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.delegate?.emailCell(self, didTapReturnButton: textField)
        return true
    }
}