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
    
    override func awakeFromNib() {
        self.usernameTextField.delegate = self
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.delegate?.emailCell(self, didTapReturnButton: textField)
        
        return true
    }
}