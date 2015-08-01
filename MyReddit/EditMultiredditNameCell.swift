//
//  EditMultiredditNameCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 7/31/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

protocol EditMultiredditNameCellDelegate {
    func editMultiredditCell(cell: EditMultiredditNameCell,
        didTapReturnButton sender: AnyObject)
}

class EditMultiredditNameCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: EditMultiredditNameCellDelegate?
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func awakeFromNib() {
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: "enter multireddit name...",
            attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        self.nameTextField.textColor = MyRedditLabelColor
        self.nameTextField.clearButtonMode = .Always
        self.nameTextField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.delegate?.editMultiredditCell(self, didTapReturnButton: textField)
        return true
    }
}