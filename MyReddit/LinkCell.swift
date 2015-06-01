//
//  LinkCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/5/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol LinkCellDelegate {
    func linkCell(cell: LinkCell, didTapImageButton sender: AnyObject)
}

class LinkCell: UITableViewCell {
    
    var delegate: LinkCellDelegate?
    
    override func awakeFromNib() {
        self.linkTextField.attributedPlaceholder = NSAttributedString(string: "enter link...",
            attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        
        if SettingsManager.defaultManager.valueForSetting(.NightMode) {
            var image = UIImage(named: "CameraWhite")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            self.addImageButton.setImage(image, forState: .Normal)
        } else {
            var image = UIImage(named: "Camera")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            self.addImageButton.setImage(image, forState: .Normal)
        }
    }
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBAction func addImageButtonTapped(sender: AnyObject) {
        self.delegate?.linkCell(self, didTapImageButton: sender)
    }
}