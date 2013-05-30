//
//  ConnectionManager.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/30/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "ConnectionManager.h"
#import "Reachability.h"
#import "MessageViewController.h"
#import "TopViewController.h"
#import "AppDelegate.h"

@implementation ConnectionManager
@synthesize internetActive, hostActive, alertShowing;

-(id)init {
    self = [super init];
    if(self) {
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    hostReachable = [Reachability reachabilityWithHostName:@"www.google.com"];
    [hostReachable startNotifier];
    
    return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
    if (buttonIndex == 0)
    {
        alertShowing = NO;
    }
}

- (void) checkNetworkStatus:(NSNotification *)notice {
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            
            if (alertShowing == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Loss" message:@"Please make sure you are connected to Internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                alertShowing = YES;
                [alert show];
            }
            break;
            
        }
        case ReachableViaWiFi:
        {
            //NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            
            break;
            
        }
        case ReachableViaWWAN:
        {
            //NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            
            break;
            
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            
            break;
            
        }
        case ReachableViaWiFi:
        {
            //NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            
            break;
            
        }
        case ReachableViaWWAN:
        {
            //NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            
            break;
            
        }
    }
    
}

// If lower than SDK 5 : Otherwise, remove the observer as pleased.

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end