//
//  PostCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/26/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PostCellDelegate {
    optional func postCell(cell: PostCell, didTapSubreddit subreddit: String?)
    optional func postCell(cell: PostCell, didShortRightSwipeForLink link: RKLink)
    optional func postCell(cell: PostCell, didLongRightSwipeForLink link: RKLink)
    optional func postCell(cell: PostCell, didShortLeftSwipeForLink link: RKLink)
    optional func postCell(cell: PostCell, didLongLeftSwipeForLink link: RKLink)
}

class PostCell: JZSwipeCell, JZSwipeCellDelegate {
    
    var link: RKLink!
    var linkComment: RKComment!
    
    var postCellDelegate: PostCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.shortSwipeLength = 300
        } else {
            self.shortSwipeLength = 150
        }
        
        let upVoteImage = UIImage(named: "Up")!.imageWithRenderingMode(.AlwaysOriginal)
        let downVoteImage = UIImage(named: "Down")!.imageWithRenderingMode(.AlwaysOriginal)
        
        self.imageSet = SwipeCellImageSetMake(downVoteImage, UIImage(named: "moreWhite"), upVoteImage, UIImage(named: "Chat"))
        self.colorSet = SwipeCellColorSetMake(MyRedditDownvoteColor, MyRedditColor, MyRedditUpvoteColor, MyRedditReplyColor)
        
        self.delegate = self
    }
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.rawValue != JZSwipeTypeNone.rawValue {
            cell.reset()
            cell.layoutSubviews()
            if swipeType.rawValue == JZSwipeTypeShortLeft.rawValue {
                self.postCellDelegate?.postCell?(self, didShortLeftSwipeForLink: self.link)
            } else if swipeType.rawValue == JZSwipeTypeShortRight.rawValue {
                self.postCellDelegate?.postCell?(self, didShortRightSwipeForLink: self.link)
            } else if swipeType.rawValue == JZSwipeTypeLongLeft.rawValue {
                self.postCellDelegate?.postCell?(self, didLongLeftSwipeForLink: self.link)
            } else {
                self.postCellDelegate?.postCell?(self, didLongRightSwipeForLink: self.link)
            }
        }
    }
}