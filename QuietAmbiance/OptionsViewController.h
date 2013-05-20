//
//  OptionsViewController.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/13/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCheckBoxView.h"

@interface OptionsViewController : UIViewController

@property (strong) NSMutableArray *cbSort;

@property (strong) NSMutableArray *cbRadius;

@property (strong) SSCheckBoxView *cbOpenNow;
@property (strong) SSCheckBoxView *cbRestaurants;
@property (strong) SSCheckBoxView *cbCafes;
@property (strong) SSCheckBoxView *cbBars;

- (void) emptyPlacesArray;

@end
