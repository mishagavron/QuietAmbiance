//
//  SearchViewController.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/6/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCheckBoxView.h"

@interface SearchViewController : UIViewController

@property (weak) IBOutlet UISegmentedControl *sortControl;
@property (weak) IBOutlet UISearchBar* searchBar;
@property (weak) IBOutlet UISlider *sliderControl;
@property (weak) IBOutlet UITableView *tableView;
@property (weak) IBOutlet UIView *myView;


- (void)loadPlaces;

- (IBAction)sortOrderChanged;


@property (strong) NSMutableArray *searchResults;
@property (strong) NSString *searchText;
@property double rowHeight;

@end
