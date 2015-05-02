//
//  PasswordCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/30/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol PasswordCellDelegate {
    func passwordCell(cell: PasswordCell, didTapReturnButton sender: AnyObject)
}


class PasswordCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: PasswordCellDelegate?
    
    var user: User! {
        didSet {
            self.passwordTextField.text = user.password
        }
    }
    
    override func awakeFromNib() {
        self.passwordTextField.delegate = self
        
        self.passwordTextField.textColor = MyRedditLabelColor
        self.passwordLabel.textColor = MyRedditLabelColor
    }
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.delegate?.passwordCell(self, didTapReturnButton: textField)
        
        return true
    }
}