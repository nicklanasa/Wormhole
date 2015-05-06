//
//  PostCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/26/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class PostCell: JZSwipeCell {
    var link: RKLink!
    var linkComment: RKComment!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.shortSwipeLength = 150
        self.imageSet = SwipeCellImageSetMake(UIImage(named: "Down"), UIImage(named: "CancelWhiteSwipe"), UIImage(named: "Up"), UIImage(named: "BookmarkSwipe"))
        self.colorSet = SwipeCellColorSetMake(MyRedditDownvoteColor, MyRedditDownvoteColor, MyRedditUpvoteColor, MyRedditColor)
    }
}