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
    
    override func awakeFromNib() {
        self.passwordTextField.delegate = self
    }
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.delegate?.passwordCell(self, didTapReturnButton: textField)
        
        return true
    }
}