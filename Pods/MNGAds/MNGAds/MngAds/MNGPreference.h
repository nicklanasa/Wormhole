//
//  MNGPreference.h
//  MNG-Ads-SDK
//
//  Created by Ben Salah Med Amine on 12/9/14.
//  Copyright (c) 2014 MNG. All rights reserved.
//

/**
 *MNGPreference class describe the preferences of ads
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, MNGGender) {
    MNGGenderUnknown,
    MNGGenderMale,
    MNGGenderFemale
};

@interface MNGPreference : NSObject

/**
 *Age of user
 */
@property NSInteger age;

/**
  Location of user
 
  @warning *Important:* your application can be rejected by Apple if you use the device's geo-location *only* for advertising.
        Your application needs to have a feature (other than advertising) using geolocation in order to be allowed to ask for the device's position.
 
 */
@property CLLocation *location;

/**
 *Language of user (ISO Code)
 */
@property NSString *language;

/**
 *The user's gender may be used to deliver more relevant ads.
 */
@property MNGGender gender;

/**
 * keyWord used for targeting.
 */
@property (copy, nonatomic)NSString *keyWord;

-(NSDictionary *)dictionaryValues;

@end
