//
//  LoadMoreHeader.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/29/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol LoadMoreHeaderDelegate {
    func loadMoreHeader(header: LoadMoreHeader, didTapButton sender: AnyObject)
}

class LoadMoreHeader: UITableViewCell {
    @IBOutlet weak var loadMoreButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var delegate: LoadMoreHeaderDelegate?
    
    override func awakeFromNib() {
        self.loadMoreButton.titleLabel?.textColor = MyRedditLabelColor
    }
    
    @IBAction func loadMoreButttonTapped(sender: AnyObject) {
        self.delegate?.loadMoreHeader(self, didTapButton: sender)
    }
    
    func startAnimating() {
        self.loadMoreButton.hidden = true
        self.activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        self.loadMoreButton.hidden = false
        self.activityIndicator.stopAnimating()
    }
}