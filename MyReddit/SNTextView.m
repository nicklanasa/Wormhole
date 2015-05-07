//
//  SNTextView.m
//  SNTextViewMore
//
//  Created by Narek Safaryan on 4/15/15.
//  Copyright (c) 2015 Narek Safaryan. All rights reserved.
//

#import "SNTextView.h"

@interface SNTextView()
@property (assign, nonatomic) CGFloat    maxHeight;
@property (strong, nonatomic) NSString   *snText;

@property (strong, nonatomic) UIButton   *moreButton;
@property (assign, nonatomic) BOOL       needToAddMoreButton;
@end

@implementation SNTextView

-(void)setSnText:(NSString *)snText
{
    _snText = snText;
}

- (void)addSeeMoreForText:(NSString *)text maxHeight:(CGFloat)maxHeight{
    [self setSnText:text];
    [self setMaxHeight:maxHeight];
    self.editable = NO;
    self.userInteractionEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.scrollEnabled = NO;
    [self setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.textContainer.lineFragmentPadding = 0.0;
    
    [self setClipsToBounds:NO];
    [self.layer setMasksToBounds:NO];
    [self setText:text];
    
    CGSize textViewSize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName : self.font}
                                                       context:nil].size;
    if (textViewSize.height > _maxHeight) {
        textViewSize.height = _maxHeight;
        self.needToAddMoreButton = YES;
    }
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, textViewSize.height)];
    
    if (!_needToAddMoreButton)
        return;
    
    CGSize moreButtonSize = CGSizeMake(80, 15);
    self.moreButton = [[UIButton alloc] init];
    [_moreButton addTarget:self action:@selector(didPressedSeeMore:) forControlEvents:UIControlEventTouchUpInside];
    [_moreButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:10]];
    [_moreButton setFrame:CGRectMake(0, 0, moreButtonSize.width, moreButtonSize.height)];
    [_moreButton setTitle:@"See more..." forState:UIControlStateNormal];
    [_moreButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self addSubview:_moreButton];
    CGRect moreButtonFrame = CGRectMake(self.frame.size.width+1, 0, _moreButton.frame.size.width, _moreButton.frame.size.height);
    NSMutableString *truncatedString = [self.text mutableCopy];
    NSRange rangeToTruncate;
    UITextPosition *pos2;
    UITextPosition *pos1;
    UITextRange *range;
    CGRect result;
    while (true) {
        pos2 = [self positionFromPosition: self.endOfDocument offset:nil];
        pos1 = [self positionFromPosition: self.endOfDocument offset:-1];
        range = [self textRangeFromPosition:pos1 toPosition:pos2];
        result = [self firstRectForRange:(UITextRange *)range ];
        result.origin.y += (result.size.height - moreButtonSize.height)/2.0;
        moreButtonFrame = CGRectMake(result.origin.x, result.origin.y+1, moreButtonSize.width, moreButtonSize.height);
        if ((moreButtonFrame.origin.x + moreButtonFrame.size.width) < self.frame.size.width) {
            break;
        }
        rangeToTruncate = NSMakeRange(truncatedString.length - 1, 1);
        [truncatedString deleteCharactersInRange:rangeToTruncate];
        [self setText:truncatedString];
        rangeToTruncate.location--;
    }
    [_moreButton setFrame:moreButtonFrame];
    [_moreButton setHidden:NO];
}

- (void)didPressedSeeMore:(UIButton *)seeMoreButton{
    NSLog(@"See more pressed...");
    if ([_snDelegate respondsToSelector:@selector(snTextView:didPressedSeeMore:)]) {
        [_snDelegate snTextView:self didPressedSeeMore:seeMoreButton];
    }
    if (_expandable) {
        CGSize textViewSize = [_snText boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName : self.font}
                                                    context:nil].size;
        [seeMoreButton removeFromSuperview];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, textViewSize.height)];
        [self setText:_snText];
        
        if ([_snDelegate respondsToSelector:@selector(snTextView:didExpanded:)]) {
            [_snDelegate snTextView:self didExpanded:self.frame.size];
        }
    }
}

@end
