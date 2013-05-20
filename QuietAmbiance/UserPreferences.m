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

@synthesize openNow,nearbyRadius,searchTypeRestaurant, searchTypeBar, searchTypeCafe, onlyZagatListed, sortOrder,radiusChoice;

typedef enum {
    
    BestMatch = -1,
    Sound = 0,
    Distance = 1,
    Rating = 2,
    Name = 3
    
} SortOrder;

typedef enum {
    
    FiveBlocks = 0,
    TenBlocks = 1,
    OneMile = 2,
    FiveMiles =3
} RadiusChoice;

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.openNow forKey:@"openNow"];
    [coder encodeDouble:self.nearbyRadius forKey:@"nearbyRadius"];
    [coder encodeBool:self.searchTypeBar forKey:@"searchTypeBar"];
    [coder encodeBool:self.searchTypeCafe forKey:@"searchTypeCafe"];
    [coder encodeBool:self.searchTypeRestaurant forKey:@"searchTypeRestaurant"];
    [coder encodeBool:self.onlyZagatListed forKey:@"onlyZagatListed"];
    [coder encodeInteger:self.sortOrder forKey:@"sortOrder"];
    [coder encodeInteger:self.radiusChoice forKey:@"radiusChice"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.openNow = (BOOL)[coder decodeBoolForKey:@"openNow"];
        self.nearbyRadius = (double) [coder decodeDoubleForKey:@"nearbyRadius"];
        self.searchTypeBar = (BOOL)[coder decodeBoolForKey:@"searchTypeBar"];
        self.searchTypeCafe = (BOOL)[coder decodeBoolForKey:@"searchTypeCafe"];
        self.searchTypeRestaurant = (BOOL)[coder decodeBoolForKey:@"searchTypeRestaurant"];
        self.onlyZagatListed  = (BOOL)[coder decodeBoolForKey:@"onlyZagatListed"];
        self.sortOrder = (NSInteger) [coder decodeIntegerForKey:@"sortOrder"];
        self.radiusChoice = (NSInteger) [coder decodeIntegerForKey:@"radiusChoice"];
    }
    return self;
}

- (void) initialize {

    self.openNow = TRUE;
    self.nearbyRadius = 500.0;
    self.radiusChoice = FiveBlocks;
    self.searchTypeBar = TRUE;
    self.searchTypeCafe = TRUE;
    self.searchTypeRestaurant = TRUE;
    self.onlyZagatListed = FALSE;
    self.sortOrder = BestMatch;
    
    return;
}

- (double) getSearchRadius {
    double ret = 0.;
    
    if (self.radiusChoice == FiveBlocks) {
        
        ret = 5.*80.0;
    } else if (self.radiusChoice == TenBlocks) {
        ret = 80.0 *10.0;
        
    } else if (self.radiusChoice == OneMile) {
        ret = 1600.0;
        
    } else if (self.radiusChoice == FiveMiles) {
        ret = 5.0*1600.0;
    }
    return ret;
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
    NSString *radius = [NSString stringWithFormat:@"&radius=%f",[appDelegate.userPreferences getSearchRadius]];
    modURL = [modURL stringByAppendingString:radius];

    
    return modURL;
}



@end
