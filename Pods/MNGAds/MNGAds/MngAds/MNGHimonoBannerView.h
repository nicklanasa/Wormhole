/*!
 *  @header    MNGHimonoBannerView.h
 *  @abstract  Himono Banner View header file.
 *  @version   2.8.2
 */

#import <UIKit/UIView.h>
#import <UIKit/UIWindow.h>

@class MNGHimonoProperties;
@protocol MNGHimonoBannerViewDelegate;

/*!
 *  `MNGHimonoBannerView` is a customized UIView that represents the himono banner.
 */
@interface MNGHimonoBannerView : UIView

/*!
 *  The object that acts as the delegate of the receiving Himono banner view.
 */
@property (nonatomic, weak, readwrite) id <MNGHimonoBannerViewDelegate> delegate;

/*!
 *  The refresh rate interval in seconds of the ads cycling.
 *
 *  @note The default value is 45sec and the minimum allowed interval is 30sec.
 */
@property (nonatomic, assign, readwrite) NSTimeInterval refreshInterval;

/*!
 *  Boolean specifying if automatic refresh should be used.
 *
 *  @discussion You should set this property to NO when hidding the Himono banner view and set it back to YES when showing is again.
 *
 *  @discussion The default value is YES.
 *
 *  @see refreshInterval
 */
@property (nonatomic, assign, readwrite) BOOL refreshAutomatically;

/*!
 *  Boolean informing whether an ad is currenly loaded in the himono banner.
 */
@property (nonatomic, assign, readonly) BOOL loaded;

/*!
 * Id of zone containing the himono
 */
@property (nonatomic, strong) NSString *publisherId;

/*!
 *  @brief Initializes and returns a new instance of MNGHimonoBannerView to the size passed in argument.
 *
 *  @param size The size of the banner view.
 *
 *  @return A new instance of MNGHimonoBannerView.
 */
- (instancetype)initWithAdSize:(CGSize)size;

/*!
 *  @brief Initializes and returns a new instance of MNGHimonoBannerView to the size passed in argument.
 *
 *  @param size The size of the banner view.
 *  @param properties The properties to customize the look of the himono view.
 *
 *  @return A new instance of MNGHimonoBannerView.
 */
- (instancetype)initWithAdSize:(CGSize)size properties:(MNGHimonoProperties *)properties;

/*!
 *  @brief Tells to the himono banner view to start showing ads.
 *
 *  @param ID of publisherId containing the himono ads, as supplied by Appsfire
 *
 *  @note Make sure to implement the delegate to be notified of ad loading or errors during the retrieval.
 */
- (void)loadAd:(NSString *)publisherId;

@end


/*!
 *  `MNGHimonoProperties` allows you to customize the look of the himono view.
 */
@interface MNGHimonoProperties : NSObject

/*!
 *  Color of the background.
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/*!
 *  Color of the title.
 */
@property (nonatomic, strong) UIColor *titleColor;

/*!
 *  Color of the tagline.
 */
@property (nonatomic, strong) UIColor *taglineColor;

/*!
 *  Color of the lines in the icon placeholder.
 */
@property (nonatomic, strong) UIColor *iconPlaceholderColor;

/*!
 *  Color of the text inside the "call to action" button.
 */
@property (nonatomic, strong) UIColor *callToActionTextColor;

/*!
 *  Array of colors for the "call to action" button.
 */
@property (nonatomic, strong) NSArray *callToActionBackgroundColors;

/*!
 *  Bool to enable/disable the animation of the "call to action" button.
 */
@property (nonatomic, assign) BOOL callToActionShouldAnimate;

/*!
 *  Interval between each animation of the "call to action" button.
 */
@property (nonatomic, assign) NSTimeInterval callToActionAnimationInterval;

@end


/*!
 *  `MNGHimonoBannerViewDelegate` provides additional information on actions performed on the himono ad.
 */
@protocol MNGHimonoBannerViewDelegate <NSObject>

@optional

/*!
 *  @brief This delegate event informs you that the himono banner view loaded an ad. You may want to show the banner view at this moment if it was previously hidden.
 *
 *  @param himonoBannerView the himono banner view at the origin of this delegate event.
 */
- (void)himonoBannerViewDidLoadAd:(MNGHimonoBannerView *)himonoBannerView;

/*!
 *  @brief This delegate event informs you that the himono banner view failed to load an ad. You may want to hide the banner view at this moment if it was previously visible.
 *
 *  @param himonoBannerView the himono banner view at the origin of this delegate event.
 *  @param error An error indicating why the ad loading failed.
 */
- (void)himonoBannerViewDidFailToLoadAd:(MNGHimonoBannerView *)himonoBannerView withError:(NSError *)error;

/*!
 *  @brief This delegate event informs you that the Appsfire SDK has recorded a click on the sashimi view.
 *
 *  @param himonoBannerView the himono banner view at the origin of this delegate event.
 */
- (void)himonoBannerViewDidRecordClick:(MNGHimonoBannerView *)himonoBannerView;

@end
