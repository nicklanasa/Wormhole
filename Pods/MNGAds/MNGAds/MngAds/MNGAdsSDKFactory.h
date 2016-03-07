//
//  MNGAdsSDKFactory.h
//  MNG-Ads-SDK
//
//  Created by Ben Salah Med Amine on 12/10/14.
//  Copyright (c) 2014 MNG. All rights reserved.
//

#import "MNGAdsAdapter.h"

void DebugLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@protocol MNGAdsSDKFactoryDelegate <NSObject>

@optional
-(void)MNGAdsSDKFactoryDidFinishInitializing;
-(void)MNGAdsSDKFactoryDidResetConfig;
@end

@interface MNGAdsSDKFactory : MNGAdsAdapter<MNGAdsAdapterBannerDelegate,MNGAdsAdapterInterstitialDelegate,MNGAdsAdapterNativeDelegate,MNGClickDelegate>

+ (void)initWithAppId:(NSString*)appId;
+ (BOOL)isInitialized;
+ (void)setDelegate:(id<MNGAdsSDKFactoryDelegate>)delegate;

@property NSString *placementId;
@property (readonly,getter=isBusy) BOOL busy;
@property BOOL isrefreshFactory;

@property (weak) id<MNGAdsAdapterNativeCollectionDelegate> nativeCollectionDelegate;

-(BOOL)createNativeCollection:(NSUInteger)count WithPreferences:(MNGPreference *)preferences;
-(BOOL)createNativeCollection:(NSUInteger)count;

+(NSString *)getAppId;
+(NSString *)getIdfa;
+(NSString *)getIdfaMD5;

//DEBUG

+(void)setDebugModeEnabled:(BOOL)enabled;

+(NSUInteger)numberOfRunningFactory;

@end
