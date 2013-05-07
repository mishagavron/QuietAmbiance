//
//  NearbyListViewController.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbyListViewController.h"

@interface NearbyListViewController : UITableViewController

//@property (strong) NSMutableArray *places;

@property double rowHeight;

@property (nonatomic,weak) IBOutlet UISegmentedControl *sortControl;

- (void)loadPlaces;
- (void)refreshTable:(UIRefreshControl *)refresh;


- (IBAction)sortOrderChanged;

@end
