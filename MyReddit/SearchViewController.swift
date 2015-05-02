//
//  SubredditSearchViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/1/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol SearchViewControllerDelegate {
    func searchViewController(controller: SearchViewController, didTapSubreddit subreddit: RKSubreddit)
}

class SearchViewController: UIViewController,
UITableViewDelegate,
    UITableViewDataSource,
    UISearchResultsUpdating,
UISearchBarDelegate {
    
    var delegate: SearchViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    var isFiltering = false
    
    @IBOutlet weak var segmentationControl: UISegmentedControl!
    
    var subreddits = Array<AnyObject>() {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    lazy var searchController: UISearchController = {
        var controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.sizeToFit()
        controller.searchBar.searchBarStyle = .Minimal
        controller.searchBar.returnKeyType = .Done
        controller.searchBar.placeholder = "Enter subreddit name..."
        return controller
    }()
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.subreddits = Array<AnyObject>()
        self.tableView.reloadData()
        
        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LoadMoreHeader {
            cell.startAnimating()
            
            if count(searchController.searchBar.text) == 0 {
                self.isFiltering = false
                self.subreddits = Array<AnyObject>()
                
                cell.stopAnimating()
            } else {
                self.isFiltering = true
                
                if self.segmentationControl.selectedSegmentIndex == 1 {
                    RedditSession.sharedSession.searchForSubredditByName(searchController.searchBar.text, pagination: nil, completion: { (pagination, results, error) -> () in
                        if error == nil {
                            if let subreddits = results {
                                self.subreddits = subreddits
                            }
                        }
                        
                        cell.stopAnimating()
                    })
                } else {
                    
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.isFiltering = false
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.becomeFirstResponder()
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        
        if self.subreddits.count > 0 {
            if let searchedSubreddits = self.subreddits[0] as? Array<RKSubreddit> {
                return searchedSubreddits.count
            }
        }
        
        return self.subreddits.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            var cell =  tableView.dequeueReusableCellWithIdentifier("LoadMoreHeader") as! LoadMoreHeader
            return cell
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell") as! SubredditCell
        
        if let subreddit = self.subreddits[0][indexPath.row] as? RKSubreddit {
            cell.rkSubreddit = subreddit
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.segmentationControl.selectedSegmentIndex == 1 {
            
            if let subreddit = self.subreddits[0][indexPath.row] as? RKSubreddit {
                self.searchController.active = false
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.delegate?.searchViewController(self, didTapSubreddit: subreddit)
                })
            }
        } else {
            
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchController.searchBar.resignFirstResponder()
    }
}