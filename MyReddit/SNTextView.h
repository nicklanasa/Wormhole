//
//  SNTextView.h
//  SNTextViewMore
//
//  Created by Narek Safaryan on 4/15/15.
//  Copyright (c) 2015 Narek Safaryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNTextView;
@protocol SNTextViewDelegate <NSObject>
@optional
- (void)snTextView:(SNTextView *)aTextView didPressedSeeMore:(UIButton *)moreButton;
- (void)snTextView:(SNTextView *)aTextView didExpanded:(CGSize)textViewSize;
@end

@interface SNTextView : UITextView

@property (weak, nonatomic) id <SNTextViewDelegate> snDelegate;
/**
 *  Flag indicates expand text view when click on more button
 */
@property (assign, nonatomic) BOOL expandable;

/**
 *  Call this method to add 'more' button in the end of the text view
 *
 *  @param text      Text which is must calculate 
 *  @param maxHeight Maximum height of text view
 */
- (void)addSeeMoreForText:(NSString *)text maxHeight:(CGFloat)maxHeight;
@end
