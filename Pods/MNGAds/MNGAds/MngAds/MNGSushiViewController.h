//
//  MNGInterstitialViewController.h
//  MNGAdServerSdk
//
//  Copyright © 2015 MNG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MNGSushiViewDelegate;

@interface MNGSushiViewController : UIViewController
@property (weak,nonatomic,nullable) UIViewController *viewController;
@property (weak,nonatomic,nullable) id<MNGSushiViewDelegate> delegate;

-(void)present;
-(void)closeAd;

@end

@protocol MNGSushiViewDelegate <NSObject>
@optional
-(void)interstitialDidAppear:(nonnull MNGSushiViewController *)sushiViewController;
-(void)interstitialWasClicked:(nonnull MNGSushiViewController *)sushiViewController;
-(void)interstitialWillDisappear:(nonnull MNGSushiViewController *)sushiViewController;

@end

