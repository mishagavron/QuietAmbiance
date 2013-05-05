//
//  Place.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject

@property (strong) NSString *name;
@property (strong) NSString *reference;
@property (strong) NSString *reference_photo;
@property (strong) NSString *rating;
@property (strong) NSString *price_level;
@property (strong) NSString *icon;
@property (strong) NSString *place_id;
@property (strong) NSString *longitude;
@property (strong) NSString *lattitude;
@property (strong) NSString *soundLevel;
@property (strong) NSString *sampleAverage;
@property (strong) NSString *vicinity;

@property double ratingNum;
@property double soundNum;
@property double distanceNumMeters;
@property double priceNum;

@property (strong) UIImage *iRating;
@property (strong) UIImage *iPhoto;
@property (strong) UIImage *iSound;



@end
