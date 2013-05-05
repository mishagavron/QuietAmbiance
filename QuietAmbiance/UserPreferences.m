//
//  UserPreferences.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/5/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "UserPreferences.h"

@implementation UserPreferences

static Boolean onlyOpenHours = TRUE;
static Boolean onlyZagatListed = FALSE;

+ (NSString*) personilizeGoogleAPIURLString:(NSString*)inputURL{
    NSString *modURL = inputURL;
    if (onlyOpenHours) {
        modURL = [modURL stringByAppendingString:@"&opennow"];
    }
    if (onlyZagatListed) {
        modURL = [modURL stringByAppendingString:@"&zagatselected"];
    }
    return modURL;
}

@end
