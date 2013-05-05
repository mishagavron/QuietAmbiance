//
//  PlaceDetails.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/25/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaceDetails : NSObject

@property (strong) NSString *phone;
@property (strong) NSString *address;
@property (strong) NSMutableArray *reviews;

@end
