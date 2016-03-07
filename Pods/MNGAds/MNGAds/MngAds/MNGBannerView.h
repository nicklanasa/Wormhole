//
//  MNGBannerView.h
//  MNGAdServerSdk
//
//  Created by Mohamed Amine Ben Salah on 9/7/15.
//  Copyright (c) 2015 MNG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


extern CGSize const kMNGAdServerSizeBanner50; //Small Banner screenWidth x 50
extern CGSize const kMNGAdServerSizeLargeBanner100; //Large Banner screenWidth x 100
extern CGSize const kMNGAdServerSizeFullBanner60; //Full Banner ipad screenWidth x 60
extern CGSize const kMNGAdServerSizeLeaderboard90; //Landscape Banner ipad screenWidth x 90
extern CGSize const kMNGAdServerSizeMediumRectangle; //Square Banner 300 x 250


@protocol MNGBannerViewDelegate;

@interface MNGBannerView : UIView<UIWebViewDelegate,UIGestureRecognizerDelegate>

+(void)setDebugEnabled:(BOOL)enabled;

-(void)loadAd;

@property (weak, nonatomic) id<MNGBannerViewDelegate> delegate;

@property (weak, nonatomic) UIViewController *viewController;
@property NSString *publisherId;
@property NSString *age;
@property NSString *zip;
@property CLLocation *location;
@property NSString *gender;
@property CGSize adSize;

@end

@protocol MNGBannerViewDelegate <NSObject>

@optional

-(void)bannerViewDidLoad:(MNGBannerView *)bannerView;
-(void)bannerView:(MNGBannerView *)bannerView didFailWithError:(NSError *)error;
-(void)bannerViewDidClicked:(MNGBannerView *)bannerView;

@end
