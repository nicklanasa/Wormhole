//
//  MNGNativeAd.h
//  MNGAdServerSdk
//
//  Copyright (c) 2015 MNG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MNGNativeAdDelegate;

typedef NS_ENUM(NSUInteger, MNGScreenshotOrientation) {
   MNGScreenshotOrientationUnknown = 0,
   MNGScreenshotOrientationPortrait,
   MNGScreenshotOrientationLandscape
};

typedef NS_ENUM(NSUInteger, MNGScreenshotType) {
   MNGScreenshotTypeUnknown = 0,
   MNGScreenshotTypeiPhone,
   MNGScreenshotTypeiPad
};

typedef NS_ENUM(NSUInteger, MNGNativeAdType) {
   MNGNativeAdTypeSushi = 1,
   MNGNativeAdTypeHimono = 2,
   MNGNativeAdTypeNative = 3,
   MNGNativeAdTypeSashimi = 5
};

@interface MNGNativeAd : NSObject

-(void)loadAd;
-(void)registerViewForInteraction:(UIView *)view withClickableView:(UIView *)clickableView;
-(void)connectViewForDisplay:(UIView *)view withClickableViews:(NSArray *)clickableViews;
-(void)disconnectViewForDisplay;
-(UIView *)getBadgeView;

@property NSString *publisherId;
@property (weak, nonatomic) id<MNGNativeAdDelegate> delegate;
@property (assign) MNGNativeAdType nativeAdType;

@property (readonly, copy) NSNumber *adid;
@property (readonly, copy) NSNumber *autoclose;
@property (readonly, copy) NSNumber *averageUserRating;
@property (readonly, copy) NSNumber *bundleID;
@property (readonly, copy) NSString *callToActionTitle;
@property (readonly, copy) NSString *localizedCallToActionTitle;
@property (readonly, copy) NSString *category;
@property (readonly, copy) NSString *categoryID;
@property (readonly, copy) NSString *clickType;
@property (readonly, copy) NSString *clickURL;
@property (readonly, copy) NSNumber *closeAppearanceDelay;
@property (readonly, copy) NSString *closePosition;
@property (readonly, copy) NSString *contentRating;
@property (readonly, copy) NSString *tagline;
@property (readonly, copy) NSString *iconURL;
@property (readonly, copy) NSArray *impURL;
@property (readonly, copy) NSNumber *price;
@property (readonly, copy) NSString *localizedPrice;
@property (readonly, copy) NSNumber *refresh;
@property (readonly, copy) NSArray *screenshotsURLs;
@property (readonly, copy) NSString *title;
@property (readonly, copy) NSNumber *userRatingCount;
@property (nonatomic, strong) NSArray *iconAvgColorComponents;
@property (readonly, assign) MNGScreenshotOrientation screenshotsOrientation;
@property (readonly, assign) MNGScreenshotType screenshotsType;
@property (readonly, assign) BOOL isFree;

@end

@protocol MNGNativeAdDelegate <NSObject>

@optional

-(void)nativeAdDidLoad:(MNGNativeAd *)nativeAd;
-(void)nativeAd:(MNGNativeAd *)nativeAd didFailWithError:(NSError *)error;
-(void)nativeAdWasClicked:(MNGNativeAd *)nativeAd;

@end
