//
//  PostTypeCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/5/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol PostTypeCellDelegate {
    func postTypeCell(cell: PostTypeCell, didChangeValue sender: AnyObject)
}

class PostTypeCell: UITableViewCell {
    
    var delegate: PostTypeCellDelegate?
    
    override func awakeFromNib() {
        self.segmentationControl.tintColor = MyRedditLabelColor
    }
    
    @IBOutlet weak var segmentationControl: UISegmentedControl!
    
    @IBAction func segmentationControlValueChanged(sender: AnyObject) {
        self.delegate?.postTypeCell(self, didChangeValue: sender)
    }
}