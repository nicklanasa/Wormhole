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
        self.updateAppearance()
    }
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBAction func addImageButtonTapped(sender: AnyObject) {
        self.delegate?.linkCell(self, didTapImageButton: sender)
    }
    
    private func updateAppearance() {
        self.linkTextField.attributedPlaceholder = NSAttributedString(string: "enter link...",
            attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        
        if SettingsManager.defaultManager.valueForSetting(.NightMode) {
            let image = UIImage(named: "CameraWhite")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            self.addImageButton.setImage(image, forState: .Normal)
        } else {
            let image = UIImage(named: "Camera")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            self.addImageButton.setImage(image, forState: .Normal)
        }
        
        self.backgroundColor = MyRedditBackgroundColor

        self.linkTextField.textColor = MyRedditLabelColor
    }
    
    override func prepareForReuse() {
        self.updateAppearance()
    }
}