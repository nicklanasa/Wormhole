/*!
 *  @header    MNGSashimiView.h
 *  @abstract  Appsfire Advertising SDK Sashimi Header
 *  @version   2.8.2
 */

#import <UIKit/UIView.h>
#import "MNGNativeAd.h"

@class AFAdSDKAdBadgeView;

typedef NS_ENUM(NSUInteger, MNGSashimiAssetType) {
   /** The icon. */
   MNGSashimiAssetTypeIcon = 0,
   /** The screenshot. */
   MNGSashimiAssetTypeScreenshot
};

@protocol MNGSashimiViewDelegate;

/*!
 *  `MNGSashimiView` is a generic adertisement view containing all the information needed to create your own sashimi ads.
 */
@interface MNGSashimiView : UIView

/*!
 * The object that acts as the delegate of the receiving sashimi view.
 *
 * @since 2.4.0
 */
@property (nonatomic, weak) id <MNGSashimiViewDelegate> delegate;

/*! 
 *  Title of the application.
 *
 *  @since 2.2.0
 */
@property (nonatomic, readonly) NSString *title;

/*!
 *  Tagline of the application.
 *
 *  @since 2.2.0
 */
@property (nonatomic, readonly) NSString *tagline;

/*!
 *  Localized category of the application.
 *
 *  @since 2.2.0
 */
@property (nonatomic, readonly) NSString *category;

/*!
 *  Localized title of the call to action view.
 *
 *  @since 2.2.0
 */
@property (nonatomic, readonly) NSString *callToActionTitle;

/*!
 *  Icon URL of the application.
 *
 *  @since 2.2.0
 */
@property (nonatomic, readonly) NSString *iconURL;

/*!
 *  Screenshot URL of the application.
 *
 *  @since 2.2.0
 */
@property (nonatomic, readonly) NSString *screenshotURL;

/*!
 *  Screenshot Type of the application.
 *
 *  @since 2.2.0
 */
@property (nonatomic, readonly) MNGScreenshotType screenshotType;

/*!
 *  Screenshot Orientation of the application.
 *
 *  @since 2.2.0
 */
@property (nonatomic, readonly) MNGScreenshotOrientation screenshotOrientation;

/*!
 *  Is App Free.
 *  
 *  @since 2.2.0
 */
@property (nonatomic, readonly) BOOL isFree;

/*!
 *  Localized price of the application.
 *
 *  @since 2.2.0
 */
@property (nonatomic, readonly) NSString *localizedPrice;

/*!
 *  The view of the appsfire badge you need to add.
 *
 *  @since 2.2.0
 */
@property (nonatomic, readonly) AFAdSDKAdBadgeView *viewAppsfireBadge;

/*!
 *  @brief Called after the view is initialized.
 *
 *  @note You should implement any initialization or user interface thing here.
 *  @note The method will be called before any draw or layout method. At this point, all properties are set and accessible.
 *
 *  @since 2.2.0
 */
- (void)sashimiIsReadyForInitialization;

/*!
 *  @brief Called when one or more properties were updated while the view was already created since some time.
 *
 *  @note For example, it is possible since sdk 2.4 that the call to action changes over time.
 *
 *  @since 2.4.0
 */
- (void)sashimiDidUpdateProperties;

/*!
 *  @brief Download an asset asynchronously.
 *
 *  @since 2.4.0
 *
 *  @param asset The asset you would like to download. The ENUM `AFAdSDKAppAssetTypeIcon` refers to the property `iconURL`, and `AFAdSDKAppAssetTypeScreenshot` to `screenshotURL`.
 *  @param completion The completion block for the callback once the asset is downloaded. If a problem occured, the `image` variable will be `nil`. Note: the block is called on the main thread.
 */
- (void)downloadAsset:(MNGSashimiAssetType)asset completion:(void (^)(UIImage *image))completion;

@end

/*!
 *  `MNGSashimiViewDelegate` provides additional information on actions performed on the sashimi view.
 */
@protocol MNGSashimiViewDelegate <NSObject>

@optional

- (void)sashimiViewDidGetSeen:(MNGSashimiView *)sashimiView;

- (void)sashimiViewDidRecordClick:(MNGSashimiView *)sashimiView;

@end
