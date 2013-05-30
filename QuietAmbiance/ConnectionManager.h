//
//  ConnectionManager.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/30/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface ConnectionManager : NSObject {
    Reachability *internetReachable;
    Reachability *hostReachable;
}

@property BOOL internetActive;
@property BOOL hostActive;
@property BOOL alertShowing;

- (void) checkNetworkStatus:(NSNotification *)notice;

@end