//
//  MNGInterstitialViewController.h
//  MNGAdServerSdk
//
//  Created by Mohamed Amine Ben Salah on 9/23/15.
//  Copyright © 2015 MNG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@protocol MNGInterstitialViewDelegate;

@interface MNGInterstitialViewController : UIViewController<UIWebViewDelegate,UIGestureRecognizerDelegate>

+(void)setDebugEnabled:(BOOL)enabled;

-(void)loadAd;
@property (weak,nonatomic,nullable) id<MNGInterstitialViewDelegate> delegate;
@property (weak,nonatomic, nullable) UIViewController *viewController;
@property NSString *publisherId;
@property NSString *age;
@property NSString *zip;
@property CLLocation *location;
@property NSString *gender;


@property BOOL isReady;
-(void)present;

@end

@protocol MNGInterstitialViewDelegate <NSObject>
@required
//
@optional
-(void)intertitialDidLoad:(nonnull MNGInterstitialViewController *)interstitialViewController;
-(void)intertitial:(nonnull MNGInterstitialViewController *)interstitialViewController didFailWithError:(nullable NSError *)error;
-(void)intertitialWillDisappear:(nonnull MNGInterstitialViewController *)interstitialViewController;
-(void)intertitialDidClicked:(MNGInterstitialViewController *)interstitialViewController;

@end
