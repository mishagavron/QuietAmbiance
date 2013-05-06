///Users/mishagavron/Documents/workspace/QuietAmbiance/ResultDetailsViewController.h
//  ResultDetailsViewController.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Place.h"
#import "PlaceDetails.h"

@interface ResultDetailsViewController : UIViewController

@property (weak)IBOutlet UILabel *lName;
@property (weak)IBOutlet UILabel *lPhone;
@property (weak)IBOutlet UILabel *lPriceLevel;
@property (weak)IBOutlet UILabel *lDistance;
@property (weak)IBOutlet UILabel *lReviewsNum;
@property (weak)IBOutlet UIImageView *iSoundLevel;
@property (weak)IBOutlet UILabel *lAddress;
@property (weak)IBOutlet UIImageView *iPhoto;
@property (weak)IBOutlet UIImageView *iRating;


@property (weak)IBOutlet UITableView *tableView;
@property (weak)IBOutlet UIScrollView *scrollView;
@property (weak)IBOutlet UIView *viewView;


@property (weak) IBOutlet UIButton *mapIt;
@property (weak) IBOutlet UIButton *callIt;


@property (strong) NSString* reference;
@property (strong) Place* place;
@property (strong) PlaceDetails* placeDetail;


@property CGFloat viewTotalHeight;

- (IBAction)mapItSelected:(id)sender;
- (IBAction)callItSelected:(id)sender;

@end
