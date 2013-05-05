//
//  Location.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *currency;
@property double lattitude;
@property double longitude;

@end
