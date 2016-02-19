//
//  SwipeCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 2/19/16.
//  Copyright © 2016 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

enum SwipeType {
    case ShortLeft
    case ShortRight
    case LongLeft
    case LongRight
}

protocol SwipeCellDelegate {
    func swipeCell(cell: SwipeCell, didTriggerSwipeWithType swipeType: SwipeType)
}

class SwipeCell: JZSwipeCell, JZSwipeCellDelegate {
    
    var swipeDelegate: SwipeCellDelegate?
    
    // Must have capacity of 4
    // Order: ShortRight, LongRight, ShortLeft, LongLeft
    var images: [UIImage]!
    
    // Must have capacity of 4
    // Order: ShortRight, LongRight, ShortLeft, LongLeft
    var colors: [UIColor]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.shortSwipeLength = 300
        } else {
            self.shortSwipeLength = 150
        }
        
        self.imageSet = SwipeCellImageSetMake(self.images[0], self.images[1], self.images[2], self.images[3])
        self.colorSet = SwipeCellColorSetMake(self.colors[0], self.colors[1], self.colors[2], self.colors[3])
        
        self.delegate = self
    }
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.rawValue != JZSwipeTypeNone.rawValue {
            cell.reset()
            cell.layoutSubviews()
            if swipeType.rawValue == JZSwipeTypeShortLeft.rawValue {
                self.swipeDelegate?.swipeCell(self, didTriggerSwipeWithType: .ShortLeft)
            } else if swipeType.rawValue == JZSwipeTypeShortRight.rawValue {
                self.swipeDelegate?.swipeCell(self, didTriggerSwipeWithType: .ShortRight)
            } else if swipeType.rawValue == JZSwipeTypeLongLeft.rawValue {
                self.swipeDelegate?.swipeCell(self, didTriggerSwipeWithType: .LongLeft)
            } else {
                self.swipeDelegate?.swipeCell(self, didTriggerSwipeWithType: .LongRight)
            }
        }
    }
}