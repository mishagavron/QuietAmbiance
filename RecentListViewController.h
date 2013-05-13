//
//  RecentListViewController.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface RecentListViewController : UITableViewController
{
    NSArray *recentList;
}

@property (strong) Place* place;
@property double rowHeight;

@end
