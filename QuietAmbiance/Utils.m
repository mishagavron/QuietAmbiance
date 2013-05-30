//
//  Utils.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "Utils.h"

@implementation Utils

static NSString *googleKey = @"AIzaSyC3G9bERz7ktJkqxvnnRx_Sb9ld8jKQErk";

+ (NSString *) getKey{
    return googleKey;
}

+ (NSString*) getSearchType{
    
    NSString *pipe = @"|";
    NSString *e_pipe = [pipe stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *type =@"restaurant";
    type = [type stringByAppendingString:e_pipe];
    type = [type stringByAppendingString:@"bar"];
    type = [type stringByAppendingString:e_pipe];
    type = [type stringByAppendingString:@"cafe"];
    return type;
    
}

+(NSString*) getSearchRadiusForCapture {
    return @"50";
}

+(NSString*) getTextSearchRadius {
    return @"1000";
}
+(CGFloat) getReviewHeaderMarginHeight {
    // if you change ReviewCell.xib for where review Y coordinate text starts, change it here as well
    return 30.0f;
}

+(CGFloat) getReviewTableVerticalOffset {
    // if you change ReviewDetailsViewController.xib for where review table Y coordinate starts, change it here as well
    return 325.0f;
}

+ (NSString *)addressComponent:(NSString *)component inAddressArray:(NSArray *)array ofType:(NSString *)type{
	int index = [array indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop){
        return [(NSString *)([[obj objectForKey:@"types"] objectAtIndex:0]) isEqualToString:component];
	}];
    
	if(index == NSNotFound) return nil;
    
	return [[array objectAtIndex:index] valueForKey:type];
}

+ (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second
{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [second drawInRect:CGRectMake(0, 0, secondWidth, secondHeight)];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSString *) mapCountryToCurrency:(NSString *) countryCode {
    
    NSString   *language = [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode];
    NSString *language_country = language;
    language_country = [language_country stringByAppendingString:@"_"];
    language_country =[language_country stringByAppendingString:countryCode];
    
    NSLocale *lcl = [[NSLocale alloc] initWithLocaleIdentifier:language_country];
    NSNumberFormatter *fmtr = [[NSNumberFormatter alloc] init];
    [fmtr setNumberStyle:NSNumberFormatterCurrencyStyle];
    [fmtr setLocale:lcl];
    
    NSLog( @"Currency Code:%@", [fmtr currencyCode] );
    NSLog( @"Currency Symbol:%@", [fmtr currencySymbol] );
    
    return [fmtr currencySymbol];
}

+ (NSString *) mapPriceToString:(NSInteger) price UsingCurrency:(NSString*) currency {
    NSString *result = @"";
    if (price <= 1 && price > 0) {
        result = [result stringByAppendingString:currency];
    }
    if (price <= 2 && price > 1) {
        result = [result stringByAppendingString:currency];
        result = [result stringByAppendingString:currency];
    }
    if (price <= 3 && price > 2) {
        result = [result stringByAppendingString:currency];
        result = [result stringByAppendingString:currency];
        result = [result stringByAppendingString:currency];
    }
    if (price <= 4 && price > 3) {
        result = [result stringByAppendingString:currency];
        result = [result stringByAppendingString:currency];
        result = [result stringByAppendingString:currency];
        result = [result stringByAppendingString:currency];
    }
    return result;
}

+ (NSString *) mapRatingToString:(double) rating {
    NSString *result = @"";
    if (rating <= 1. && rating > 0.) {
        result = [result stringByAppendingString:@"*"];
    }
    if (rating <= 2. && rating > 1.) {
        result = [result stringByAppendingString:@"**"];
    }
    if (rating <= 3. && rating > 2.) {
        result = [result stringByAppendingString:@"***"];
    }
    if (rating <= 4. && rating > 3.) {
        result = [result stringByAppendingString:@"****"];
    }
    if (rating <= 5. && rating > 4.) {
        result = [result stringByAppendingString:@"*****"];
    }
    
    return result;
}

+ (UIImage *) mapRatingToImage:(double) rating {
    
    UIImage *img = [[UIImage alloc] init];
    
    if (rating ==0.0) {
        img = [UIImage imageNamed:@"star_0_0.png"];
    }
    else if (rating <= 0.5 && rating > 0.0) {
        img = [UIImage imageNamed:@"star_0_5.png"];
    }   
    else if (rating <= 1. && rating > 0.5) {
        img = [UIImage imageNamed:@"star_1_0.png"];
    }
    else if (rating <= 1.5 && rating > 1.) {
        img = [UIImage imageNamed:@"star_1_5.png"];
    }
    else if (rating <= 2. && rating > 1.5) {
        img = [UIImage imageNamed:@"star_2_0.png"];
    }
    else if (rating <= 2.5 && rating > 1.5) {
        img = [UIImage imageNamed:@"star_2_5.png"];
    }
    else if (rating <= 3. && rating > 2.5) {
        img = [UIImage imageNamed:@"star_3_0.png"];
    }
    else if (rating <= 3.5 && rating > 3.) {
        img = [UIImage imageNamed:@"star_3_5.png"];
    }
    else if (rating <= 4. && rating > 3.5) {
        img = [UIImage imageNamed:@"star_4_0.png"];
    }
    else if (rating <= 4.5 && rating > 4.) {
        img = [UIImage imageNamed:@"star_4_5.png"];
    }
    else if (rating <= 5. && rating > 4.5) {
        img = [UIImage imageNamed:@"star_5_0.png"];
    }
    return img;
}

+ (UIImage *) mapAmbianceToImage:(double) rating {
    
    UIImage *img = [[UIImage alloc] init];
    
    if (rating < 20.00) {
        img = [UIImage imageNamed:@"quiet_5.png"];
    }
    else if (rating >= 20.00 && rating < 45.00) {
        img = [UIImage imageNamed:@"quiet_4.png"];
    }
    else if (rating >= 30.00 && rating < 50.00) {
        img = [UIImage imageNamed:@"quiet_3.png"];
    }
    else if (rating >= 40.00 && rating < 55.00) {
        img = [UIImage imageNamed:@"quiet_2.png"];
    }
    else if (rating >= 50.00 && rating < 65.00) {
        img = [UIImage imageNamed:@"quiet_1.png"];
    }
    else if (rating >= 60.00 && rating < 70.00) {
        img = [UIImage imageNamed:@"loud_1.png"];
    }
    else if (rating >= 70.00 && rating < 75.00) {
        img = [UIImage imageNamed:@"loud_2.png"];
    }
    else if (rating >= 80.00 && rating < 85.00) {
        img = [UIImage imageNamed:@"loud_3.png"];
    }
    else if (rating >= 85.00 && rating < 90.00) {
        img = [UIImage imageNamed:@"loud_4.png"];
    }
    else if (rating >= 90) {
        img = [UIImage imageNamed:@"loud_5.png"];
    }
    
    return img;
}


+ (CLLocationDistance) distanceInMeters:(CLLocation *)from To:(CLLocation *)to {
    CLLocationDistance distance = [from distanceFromLocation:to];
    return (distance);
    
}
+ (CLLocationDistance) distanceInMiles:(CLLocation*) from To:(CLLocation*) to {
    CLLocationDistance distance = [from distanceFromLocation:to];
    return (distance * 0.000621371);

}
+ (CLLocationDistance) distanceInFeet:(CLLocation*) from To:(CLLocation*) to {
    CLLocationDistance distance = [from distanceFromLocation:to];
    return (distance * 3.28084);
}
+ (NSString*) distanceString:(CLLocation*) from To:(CLLocation*) to {
    NSString *distanceStr = @"";
    CLLocationDistance distance = [from distanceFromLocation:to];
    if (distance < 75.) {
        distanceStr = [NSString stringWithFormat:@"%.0fft",(distance * 3.28084) ];
    } else {
        distanceStr = [NSString stringWithFormat:@"%.1fmi",(distance * 0.000621371) ];
    }
    return distanceStr;
}

+ (NSString*) convertEscapeTexttoPlainText:(NSString*) input {
    input = [input stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    input = [input stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    input = [input stringByReplacingOccurrencesOfString:@"&quot;" withString:@"'"];
    return input;
}


@end
