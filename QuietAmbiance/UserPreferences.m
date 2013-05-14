//
//  UserPreferences.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/5/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "UserPreferences.h"
#import "AppDelegate.h"

@implementation UserPreferences

@synthesize openNow,nearbyRadius,searchTypeRestaurant,searchRadius, searchTypeBar, searchTypeCafe, onlyZagatListed, sortOrder;

typedef enum {
    
    BestMatch = -1,
    Sound = 0,
    Distance = 1,
    Rating = 2,
    Name = 3
    
} SortOrder;

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.openNow forKey:@"openNow"];
    [coder encodeDouble:self.nearbyRadius forKey:@"nearbyRadius"];
    [coder encodeDouble:self.searchRadius forKey:@"searchRadius"];
    [coder encodeBool:self.searchTypeBar forKey:@"searchTypeBar"];
    [coder encodeBool:self.searchTypeCafe forKey:@"searchTypeCafe"];
    [coder encodeBool:self.searchTypeRestaurant forKey:@"searchTypeRestaurant"];
    [coder encodeBool:self.onlyZagatListed forKey:@"onlyZagatListed"];
    [coder encodeInteger:self.sortOrder forKey:@"sortOrder"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.openNow = (BOOL)[coder decodeBoolForKey:@"openNow"];
        self.nearbyRadius = (double) [coder decodeDoubleForKey:@"nearbyRadius"];
        self.searchRadius = (double) [coder decodeDoubleForKey:@"searchRadius"];
        self.searchTypeBar = (BOOL)[coder decodeBoolForKey:@"searchTypeBar"];
        self.searchTypeCafe = (BOOL)[coder decodeBoolForKey:@"searchTypeCafe"];
        self.searchTypeRestaurant = (BOOL)[coder decodeBoolForKey:@"searchTypeRestaurant"];
        self.onlyZagatListed  = (BOOL)[coder decodeBoolForKey:@"onlyZagatListed"];
        self.sortOrder = (NSInteger) [coder decodeIntegerForKey:@"sortOrder"];
    }
    return self;
}

- (void) initialize {

    self.openNow = TRUE;
    self.nearbyRadius = 500.0;
    self.searchRadius = 1000.0;
    self.searchTypeBar = TRUE;
    self.searchTypeCafe = TRUE;
    self.searchTypeRestaurant = TRUE;
    self.onlyZagatListed = FALSE;
    self.sortOrder = BestMatch;
    
    return;
}

- (NSString*) personilizeGoogleAPIURLString:(NSString*)inputURL{
    NSString *modURL = inputURL;
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (self.openNow) {
        modURL = [modURL stringByAppendingString:@"&opennow"];
    }
    
    NSString *pipe = @"|";
    NSString *e_pipe = [pipe stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *type =@"";
    Boolean typeFound = FALSE;
    if (self.searchTypeRestaurant) {
        type = [type stringByAppendingString:@"restaurant"];
        typeFound = TRUE;
    }
    if (self.searchTypeBar) {
        if (typeFound){
            type = [type stringByAppendingString:e_pipe];
            type = [type stringByAppendingString:@"bar"];
        }
        else {
            type = [type stringByAppendingString:@"bar"];
        }
        typeFound = TRUE;
    }
    if (self.searchTypeCafe) {
        if (typeFound){
            type = [type stringByAppendingString:e_pipe];
            type = [type stringByAppendingString:@"cafe"];
        }
        else {
            type = [type stringByAppendingString:@"cafe"];
        }
        typeFound = TRUE;
    }
    if (type.length > 0){
        type = [NSString stringWithFormat:@"&types=%@",type];
        modURL = [modURL stringByAppendingString:type];
    }
    if (self.onlyZagatListed) {
        modURL = [modURL stringByAppendingString:@"&zagatselected"];
    }
    NSString *radius = [NSString stringWithFormat:@"&radius=%f",appDelegate.userPreferences.searchRadius];
    modURL = [modURL stringByAppendingString:radius];

    
    return modURL;
}



@end
