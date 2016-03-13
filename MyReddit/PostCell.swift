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
    optional func postCell(cell: PostCell, didTapComments link: RKLink)
    optional func postCell(cell: PostCell, didLongHoldWith subreddit: String?)
    optional func postCell(cell: PostCell, didTapSubreddit subreddit: String?)
    optional func postCell(cell: PostCell, didShortRightSwipeForLink link: RKLink)
    optional func postCell(cell: PostCell, didLongRightSwipeForLink link: RKLink)
    optional func postCell(cell: PostCell, didShortLeftSwipeForLink link: RKLink)
    optional func postCell(cell: PostCell, didLongLeftSwipeForLink link: RKLink)
}

class PostCell: SwipeCell, SwipeCellDelegate {
    
    @IBOutlet weak var subredditButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var postInfoLabel: UILabel!

    var link: RKLink!
    var linkComment: RKComment!
    
    var postCellDelegate: PostCellDelegate?
    
    override func awakeFromNib() {
        let upVoteImage = UIImage(named: "Up")!.imageWithRenderingMode(.AlwaysOriginal)
        let downVoteImage = UIImage(named: "Down")!.imageWithRenderingMode(.AlwaysOriginal)
        
        self.images = [downVoteImage, UIImage(named: "ShareWhite")!, upVoteImage, UIImage(named: "moreWhite")!]
        self.colors = [MyRedditDownvoteColor, MyRedditColor, MyRedditUpvoteColor, MyRedditReplyColor]

        super.awakeFromNib()

        let infoTapGesture = UITapGestureRecognizer(target: self, action: "infoTapped:")
        infoTapGesture.numberOfTapsRequired = 1
        self.postInfoLabel.gestureRecognizers = [infoTapGesture]

        self.swipeDelegate = self
        
        self.postInfoLabel.font = MyRedditCommentInfoFont
        self.scoreLabel.font = MyRedditFont
        self.subredditButton.titleLabel?.font = MyRedditFont
    }

    func infoTapped(sender: AnyObject) {
        self.postCellDelegate?.postCell?(self, didTapComments: self.link)
    }
    
    func swipeCell(cell: SwipeCell, didTriggerSwipeWithType swipeType: SwipeType) {
        switch swipeType {
        case .LongRight: self.postCellDelegate?.postCell?(self, didLongRightSwipeForLink: self.link)
        case .LongLeft: self.postCellDelegate?.postCell?(self, didLongLeftSwipeForLink: self.link)
        case .ShortRight: self.postCellDelegate?.postCell?(self, didShortRightSwipeForLink: self.link)
        default: self.postCellDelegate?.postCell?(self, didShortLeftSwipeForLink: self.link)
        }
    }
    
    func updateAppearance() {
        self.backgroundColor = MyRedditBackgroundColor
        self.contentView.backgroundColor = MyRedditBackgroundColor
        self.postInfoLabel.backgroundColor = UIColor.clearColor()
        self.postInfoLabel.textColor = MyRedditLabelColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
