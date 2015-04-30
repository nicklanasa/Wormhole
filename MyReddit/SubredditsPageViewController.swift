//
//  SubredditsPageViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/28/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

class SubredditsPageViewController: UIViewController,
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        pageViewController = segue.destinationViewController as! UIPageViewController
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers([subredditViewControllerForIndex(0)],
            direction: UIPageViewControllerNavigationDirection.Forward,
            animated: false,
            completion: nil)
        pageViewController.automaticallyAdjustsScrollViewInsets = false
    }
    
    // MARK: - PageViewController
    
    let onBoardText = [ NSLocalizedString("OnBoardStrength", comment: ""),
        NSLocalizedString("OnBoardHealth", comment: ""),
        NSLocalizedString("OnBoardSuccess", comment: "") ]
    
    let onBoardHeader = [ "StrengthHeader", "HealthHeader", "SuccessHeader" ]
    
    var numberOfOnBoardItems: Int {
        get {
            return onBoardText.count
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return numberOfOnBoardItems
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            if let itemController = viewController as? SubredditViewController {
                let index = itemController.pageIndex
                
                if index > 0 {
                    return subredditViewControllerForIndex(index - 1)
                }
            }
            return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            if let itemController = viewController as? SubredditViewController {
                let index = itemController.pageIndex
                
                if index < numberOfOnBoardItems - 1 {
                    return subredditViewControllerForIndex(index + 1)
                }
            }
            return nil
    }
    
    private func subredditViewControllerForIndex(index: Int) -> SubredditViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        var vc = sb.instantiateViewControllerWithIdentifier("SubredditViewController")
            as! SubredditViewController
        
        // Access the vc's view to force the IBOutlets to instantiate.
        if vc.view != nil {
            //vc.subreddit =
        }
        vc.pageIndex = index
        return vc
    }
}