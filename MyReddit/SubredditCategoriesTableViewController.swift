//
//  SubredditCategoriesTableViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 7/31/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

class SubredditCategoriesTableViewController: RootTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    let categories = ["Animals",
        "Apple Related",
        "Ask Redditors",
        "Books and Reading",
        "Design", "Education",
        "Entertainment", "Games",
        "Gender and Relationships",
        "Lifestyle", "Humor",
        "Media and Art", "Money",
        "Music", "News",
        "Politics", "Reddit Related",
        "Religion", "Science",
        "Self Help", "Sports", "Technology"]

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SubredditCategoryCell") as! SubredditCell
        cell.nameLabel.text = self.categories[indexPath.row].lowercaseString
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? SubredditCell {
            if let indexPath = self.tableView.indexPathForCell(cell) {
                if let controller = segue.destinationViewController as? SubredditsByCategoryTableViewController {
                    controller.category = self.categories[indexPath.row]
                }
            }
        }
    }
}
