//
//  Protocols.h
//  MNG-Ads-SDK
//
//  Created by Ben Salah Med Amine on 12/9/14.
//  Copyright (c) 2014 MNG. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MNGAdsAdapter,MNGNAtiveObject;

/**
 
 The delegate of a MNGAdsAdapter object must adopt the MNGAdsAdapterBannerDelegate protocol.
 
 Many methods of MNGAdsAdapterBannerDelegate return the ad view sent by the message.
 The protocol methods allow the delegate to be aware of the ad-related events.
 You can use it to handle your app's or the ad's behavior like adapting your viewController's view size depending on the ad being displayed or not.
 
 */


@protocol MNGAdsAdapterBannerDelegate <NSObject>

@optional

/** Notifies the delegate that the creative from the banner ad has been loaded.
 
 @param adView An ad view object informing the delegate about the banner being loaded.
 
 */

- (void)adsAdapter:(MNGAdsAdapter *)adsAdapter bannerDidLoad:(UIView *)adView preferredHeight:(CGFloat)preferredHeight;

/** Notifies the delegate that the creative from the banner ad has been failed.
 
 @param adView An ad view object informing the delegate about the banner being failed.
 
 */

- (void)adsAdapter:(MNGAdsAdapter *)adsAdapter bannerDidFailWithError:(NSError *)error;

-(void)adsAdapter:(MNGAdsAdapter *)adsAdapter bannerDidChangeFrame:(CGRect)frame;

@end

/**
 
 The delegate of a MNGAdsAdapter object must adopt the MNGAdsAdapterInterstitialDelegate protocol.
 
 Many methods of MNGAdsAdapterInterstitialDelegate return the ad view sent by the message.
 The protocol methods allow the delegate to be aware of the ad-related events.
 You can use it to handle your app's or the ad's behavior like adapting your viewController's view size depending on the ad being displayed or not.
 
 */


@protocol MNGAdsAdapterInterstitialDelegate <NSObject>

@optional

/** Notifies the delegate that the creative from the interstitial ad has been loaded.
 
 @param adView An ad view object informing the delegate about the interstitial being loaded.
 
 */

- (void)adsAdapterInterstitialDidLoad:(MNGAdsAdapter *)adsAdapter;

/** Notifies the delegate that the creative from the interstitial ad has been disappeared.
 
 @param adView An ad view object informing the delegate about the interstitial being disappeared.
 
 */

- (void)adsAdapterInterstitialDisappear:(MNGAdsAdapter *)adsAdapter;

/** Notifies the delegate that the creative from the interstitial ad has been failed.
 
 @param adView An ad view object informing the delegate about the interstitial being failed.
 
 */

- (void)adsAdapter:(MNGAdsAdapter *)adsAdapter interstitialDidFailWithError:(NSError *)error;

@end

/**
 
 The delegate of a MNGAdsAdapter object must adopt the MNGAdsAdapterNativeDelegate protocol.
 
 Many methods of MNGAdsAdapterNativeDelegate return the ad view sent by the message.
 The protocol methods allow the delegate to be aware of the ad-related events.
 You can use it to handle your app's or the ad's behavior like adapting your viewController's view size depending on the ad being displayed or not.
 
 */


@protocol MNGAdsAdapterNativeDelegate <NSObject>

@optional

/** Notifies the delegate that the creative from the nativeObject ad has been loaded.
 
 @param adView An ad view object informing the delegate about the nativeObject being loaded.
 
 */

- (void)adsAdapter:(MNGAdsAdapter *)adsAdapter nativeObjectDidLoad:(MNGNAtiveObject *)adView;

/** Notifies the delegate that the creative from the nativeObject ad has been failed.
 
 @param adView An ad view object informing the delegate about the nativeObject being failed.
 
 */

- (void)adsAdapter:(MNGAdsAdapter *)adsAdapter nativeObjectDidFailWithError:(NSError *)error;

@end

@protocol MNGAdsAdapterNativeCollectionDelegate <NSObject>

@optional

/** Notifies the delegate that the creative from the nativeObjects ad has been loaded.
 
 @param adView An ad view object informing the delegate about the nativeObject being loaded.
 
 */

- (void)adsAdapter:(MNGAdsAdapter *)adsAdapter nativeCollectionDidLoad:(NSArray *)adView;

/** Notifies the delegate that the creative from the nativeCollection ad has been failed.
 
 @param adView An ad view object informing the delegate about the nativeObject being failed.
 
 */

- (void)adsAdapter:(MNGAdsAdapter *)adsAdapter nativeCollectionDidFailWithError:(NSError *)error;

@end


@protocol MNGClickDelegate <NSObject>

@optional

-(void)adsAdapterAdWasClicked:(MNGAdsAdapter *)adsAdapter;

@end


