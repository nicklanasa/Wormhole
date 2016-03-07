//
//  MNGDisplayableNativeAd.h
//  MNGAdServerSdk
//
//  Copyright (c) 2015 MNG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNGNativeAd.h"
#import "MNGSushiViewController.h"
#import "MNGSashimiView.h"

@interface MNGDisplayableNativeAd : MNGNativeAd

-(MNGSushiViewController *)getSushiViewController;
-(MNGSashimiView *)getMinimalSashimiViewWithFrame:(CGRect)frame;
-(MNGSashimiView *)getExtendedSashimiViewWithFrame:(CGRect)frame;
-(MNGSashimiView *)getSashimiViewForSubclass:(Class)viewClass withFrame:(CGRect)frame;

@end
