//
//  PostCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/26/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol PostCellDelegate {
    func postCell(cell: PostCell, didTapSubreddit subreddit: String?)
}

class PostCell: JZSwipeCell {
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
        
        var upVoteImage = UIImage(named: "Up")!.imageWithRenderingMode(.AlwaysOriginal)
        var downVoteImage = UIImage(named: "Down")!.imageWithRenderingMode(.AlwaysOriginal)
        
        self.imageSet = SwipeCellImageSetMake(downVoteImage, UIImage(named: "ShareWhite"), upVoteImage, UIImage(named: "moreWhite"))
        self.colorSet = SwipeCellColorSetMake(MyRedditDownvoteColor, MyRedditColor, MyRedditUpvoteColor, MyRedditReplyColor)
    }
    
    func upvote() {
    }
    
    func downvote() {
    }
    
    func unvote() {
    }
}