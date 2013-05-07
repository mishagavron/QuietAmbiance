//
//  Place.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "Place.h"

@implementation Place

@synthesize name, reference, place_id, icon, rating, price_level, longitude, lattitude, soundLevel, sampleAverage,vicinity,iPhoto,iSound,iRating;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.iRating = nil;
        self.iSound = nil;
        self.iPhoto = nil;
    }
    return self;
}
@end
