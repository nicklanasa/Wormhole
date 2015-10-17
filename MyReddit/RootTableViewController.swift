//
//  RootTableViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 7/31/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

class RootTableViewController: UITableViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateAppearance()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateAppearance()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredAppearance",
            name: MyRedditAppearanceDidChangeNotification,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: MyRedditAppearanceDidChangeNotification,
            object: nil)
    }
    
    private func updateAppearance() {
        self.tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MyRedditLabelColor,
            NSFontAttributeName : MyRedditTitleFont]
        self.tableView.backgroundColor = MyRedditBackgroundColor
        self.tableView.tableFooterView = UIView()
    }
    
    func preferredAppearance() {
        self.updateAppearance()
    }
}
