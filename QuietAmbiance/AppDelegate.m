//
//  AppDelegate.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "AppDelegate.h"
#import "Utils.h"
#import "Utils.h"
#import "Place.h"
#import "ResultCell.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#include "AFImageRequestOperation.h"
#include "UserPreferences.h"

@implementation AppDelegate

@synthesize locationManager=_locationManager, places, recentPlaces, recentSearches, userPreferences;

-(void) loadLocaleFromAPI:(CLLocation *)location {
    
    NSString *lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *longt = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    //NSString *gKey = @"AIzaSyC3G9bERz7ktJkqxvnnRx_Sb9ld8jKQErk";
    //NSString *radius = @"100";
    //NSString *pipe = @"|";
    //NSString *e_pipe = [pipe stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSString *type =@"restaurant";
    //type = [type stringByAppendingString:e_pipe];
    //type = [type stringByAppendingString:@"bar"];
    NSString *placeString  = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true",lat,longt];
    NSLog(@"request string: %@",placeString);
    
    NSURL *placeURL = [NSURL URLWithString:placeString];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:placeURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    [request setHTTPMethod:@"GET"];
    NSURLResponse* response;
    NSError* error = nil;
    
    //Capturing server response
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response       error:&error];
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&myError];
    
    
    NSArray *firstResultAddress = [[[res objectForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"];
    
    
    NSString *countryName = [Utils addressComponent:@"country" inAddressArray:firstResultAddress ofType:@"short_name"];
    NSString *currencySymbol = [Utils mapCountryToCurrency:countryName];
    
    NSLog(@"CurrencyCode: %@", countryName);
    NSLog(@"Country Code: %@", currencySymbol);
    NSLog(@"Longitute: %@", longt);
    NSLog(@"Lattitude: %@", lat);
    
    if (self.currentLocation == nil){
        self.currentLocation = [[Location alloc] init];
    }
    self.currentLocation.country = [[NSString alloc] initWithString:countryName];
    self.currentLocation.currency = [[NSString alloc] initWithString:currencySymbol];
    self.currentLocation.lattitude = location.coordinate.latitude;
    self.currentLocation.longitude = location.coordinate.longitude;
    

}

#pragma mark - CLLocationManagerDelegate Methods
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSDate* eventDate = newLocation.timestamp;

    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        //Location timestamp is within the last 15.0 seconds, let's use it!
        //NSLog(@"Horizonatal Accuracy %f",newLocation.horizontalAccuracy);
        if(newLocation.horizontalAccuracy<100.0 && newLocation.verticalAccuracy<100.0){
            //Location seems pretty accurate, let's use it!
            NSLog(@"latitude %+.6f, longitude %+.6f\n",
                  newLocation.coordinate.latitude,
                  newLocation.coordinate.longitude);
            NSLog(@"Horizontal Accuracy:%f", newLocation.horizontalAccuracy);
            
            if ((self.currentLocation.lattitude != self.locationManager.location.coordinate.latitude) ||
                (self.currentLocation.longitude != self.locationManager.location.coordinate.longitude)) {
                [self loadLocaleFromAPI:newLocation];
                self.locationState = Defined;
                self.currentLocation.lattitude = newLocation.coordinate.latitude;
                self.currentLocation.longitude = newLocation.coordinate.longitude;
                //clear places array
                if (self.places != nil) {
                    [self.places removeAllObjects];
                }
            }
            
            //Optional: turn off location services once we've gotten a good location
            //[manager stopUpdatingLocation];
            
        }
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //If object has not been created, create it.
    if(self.locationManager==nil){
        _locationManager=[[CLLocationManager alloc] init];
        //I'm using ARC with this project so no need to release
        
        _locationManager.delegate=self;
        
        //Included in the prompt to use location services
        //_locationManager.purpose = @"We will try to tell you where you are if you get lost";
        
        
        //The desired accuracy that you want, not guaranteed though
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        
        //The distance in meters a device must move before an update event is triggered
        _locationManager.distanceFilter=10;
        self.locationManager=_locationManager;
    
        if (self.currentLocation == nil){
            self.currentLocation = [[Location alloc] init];
        }
        self.currentLocation.country = @"USA";
        self.currentLocation.currency = @"$";
        self.currentLocation.lattitude = self.locationManager.location.coordinate.latitude;
        self.currentLocation.longitude = self.locationManager.location.coordinate.longitude;
        
        if (self.currentLocation.lattitude != 0.) {
            self.locationState = Defined;
        } else {
            self.locationState = Undefined;
        }
    }
    
    if([CLLocationManager locationServicesEnabled]){
        [self.locationManager startUpdatingLocation];
        //[self.currentLocation init];
    }
    
    // load user options
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"options";
    
    NSData *myEncodedUserPreference = [defaults objectForKey:key];
    self.userPreferences =  (UserPreferences *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedUserPreference];
    
    if (self.userPreferences == nil) {
        self.userPreferences = [UserPreferences alloc];
        [self.userPreferences initialize];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
       [self.locationManager stopUpdatingLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
