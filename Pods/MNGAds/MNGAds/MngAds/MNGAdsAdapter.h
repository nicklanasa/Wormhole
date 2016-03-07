//
//  MNGAdsAdapter.h
//  MNG-Ads-SDK
//
//  Created by Ben Salah Med Amine on 12/9/14.
//  Copyright (c) 2014 MNG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNGPreference.h"
#import "Protocols.h"

/**
 Enumeration that define the type of requested ad
 */
typedef NS_ENUM(NSInteger, MNGAdsType) {
    MNGAdsTypeBanner, //Banner ad
    MNGAdsTypeInterstitial, //Interstitial ad
    MNGAdsTypeNative //Native ad
};
/**
 MNGAdSize the same of CGRect
 */
typedef CGRect MNGAdSize;

extern MNGAdSize const kMNGAdSizeBanner; //Small Banner 320 x 50
extern MNGAdSize const kMNGAdSizeLargeBanner; //Large Banner 320 x 100
extern MNGAdSize const kMNGAdSizeFullBanner; //Full Banner ipad 468 x 60
extern MNGAdSize const kMNGAdSizeLeaderboard; //Landscape Banner ipad 728 x 80
extern MNGAdSize const kMNGAdSizeMediumRectangle; //Square Banner 300 x 250

/**
 MNGAdsAdapter is an abstract class that allow communication between the SDK and any Ads server
 */

@interface MNGAdsAdapter : NSObject

/**
 *The parameters of initialisation
 */

@property NSDictionary *parameters;

/**
  viewController that th ad will be showen
 @warning required in interstitial
 */

@property (weak) UIViewController *viewController;

@property (atomic) BOOL completed;

/**
 *timeout of one ads server
 */

@property NSTimeInterval timeout;


/**
 *Delegates
 */

@property (weak) id<MNGAdsAdapterBannerDelegate> bannerDelegate;

@property (weak) id<MNGAdsAdapterInterstitialDelegate> interstitialDelegate;

@property (weak) id<MNGAdsAdapterNativeDelegate> nativeDelegate;

@property (weak) id<MNGClickDelegate> clickDelegate;

/** Init the Ads server
 Any Ads server need some parameters to be inited
 
 @param parameters the parameters of initialisation
 
 */

-(id)initWithParameters:(NSDictionary*)parameters;

/** Create a banner view
 request a banner view from the SDK that will be returned in the delegate methods
 
 @param preferences user's preferences
 
 @return success
 */

-(BOOL)createBannerInFrame:(CGRect)frame withPreferences:(MNGPreference*)preferences;
-(BOOL)createBannerInFrame:(CGRect)frame ;

/** Create a interstitial view
 request a interstitial view from the SDK that will be returned in the delegate methods
 
 @param preferences user's preferences

 
 @return success
 */

-(BOOL)createInterstitialWithPreferences:(MNGPreference*)preferences;
-(BOOL)createInterstitial;



/** Create a native Ads view
 request a native object from the SDK that will be returned in the delegate methods
 
 @param preferences user's preferences
 
 @return success
 */

-(BOOL)createNativeWithPreferences:(MNGPreference*)preferences;
-(BOOL)createNative;

-(void)releaseMemory;

@end
