//
//  AppDelegate.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <UIKit/UIKit.h>
//Add Location Framework
#import <CoreLocation/CoreLocation.h>
#import "Location.h"

typedef enum {
    
    Undefined = 1,
    Defined = 2
    
} LocationType;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) Location *currentLocation;
@property (strong) NSMutableArray *places;
@property LocationType locationState;

-(void) loadLocaleFromAPI:(CLLocation *)location;

@end
