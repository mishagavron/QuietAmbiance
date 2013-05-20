//
//  Utils.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@interface Utils : NSObject

+ (NSString *) mapCountryToCurrency:(NSString *) country;
+ (NSString *) mapPriceToString:(NSInteger) price UsingCurrency:(NSString*) currency;
+ (NSString *) mapRatingToString:(double) rating;
+ (UIImage *) mapRatingToImage:(double) rating;
+ (UIImage *) mapAmbianceToImage:(double) rating;
+ (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second;
+ (NSString *)addressComponent:(NSString *)component inAddressArray:(NSArray *)array ofType:(NSString *)type;
+ (CLLocationDistance) distanceInMiles:(CLLocation*) from To:(CLLocation*) to;
+ (CLLocationDistance) distanceInFeet:(CLLocation*) from To:(CLLocation*) to;
+ (CLLocationDistance) distanceInMeters:(CLLocation*) from To:(CLLocation*) to;
+ (NSString*) distanceString:(CLLocation*) from To:(CLLocation*) to;
+ (NSString*) convertEscapeTexttoPlainText:(NSString*) input;

+ (NSString *)getKey;
+ (NSString *)getSearchType;
+ (NSString *)getSearchRadiusForCapture;
+ (NSString *)getTextSearchRadius;
+ (CGFloat) getReviewHeaderMarginHeight;
+ (CGFloat) getReviewTableVerticalOffset;

@end
