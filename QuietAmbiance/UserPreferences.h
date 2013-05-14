//
//  UserPreferences.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/5/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserPreferences : NSObject

@property BOOL openNow;
@property double nearbyRadius;
@property double searchRadius;
@property BOOL searchTypeBar;
@property BOOL searchTypeCafe;
@property BOOL searchTypeRestaurant;
@property BOOL onlyZagatListed;
@property NSInteger sortOrder;

- (void) initialize;
- (NSString*) personilizeGoogleAPIURLString:(NSString*)input;

@end
