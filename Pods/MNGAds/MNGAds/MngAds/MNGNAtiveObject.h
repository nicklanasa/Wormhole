//
//  MNGNAtiveObject.h
//  MNG-Ads-SDK
//
//  Created by Ben Salah Med Amine on 12/9/14.
//  Copyright (c) 2014 MNG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNGPriceType) {
    MNGPriceTypeFree,
    MNGPriceTypePayable,
    MNGPriceTypeUnknown
};

@interface MNGNAtiveObject : NSObject

@property NSString *title;
@property NSString *socialContext;
@property NSString *body;
@property NSString *callToAction;
@property NSURL *photoUrl;
@property NSURL *coverImageUrl;
@property UIView *badgeView;
@property MNGPriceType priceType;
@property NSString *localizedPrice;
@property (nonatomic, copy) void (^mediaContainerBlock)(UIView *mediaContainer);

- (void)registerViewForInteraction:(UIView *)view
                withViewController:(UIViewController *)viewController
                withClickableView:(UIView *)clickableView;

- (void)setMediaContainer:(UIView *)mediaContainer;
@end
