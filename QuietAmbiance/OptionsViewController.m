//
//  OptionsViewController.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/13/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "OptionsViewController.h"
#import "SSCheckBoxView.h"
#import "AppDelegate.h"
#import "ActivityViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface OptionsViewController ()

@end

@implementation OptionsViewController

@synthesize cbOpenNow, cbRadius, cbSort, cbBars, cbCafes, cbRestaurants;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) checkBoxSortChangedState:(SSCheckBoxView *)cbvIn
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    // toggle all
    for (SSCheckBoxView *cbv in self.cbSort) {
        if (cbv.tag == cbvIn.tag) {
            cbv.checked = TRUE;
        } else {
            cbv.checked = FALSE;
        }
    }
    appDelegate.userPreferences.sortOrder = cbvIn.tag;
}

- (void) emptyPlacesArray {
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.places != nil) {
        [appDelegate.places removeAllObjects];
    }
}

- (void) checkBoxRadiusChangedState:(SSCheckBoxView *)cbvIn
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    // toggle all
    for (SSCheckBoxView *cbv in self.cbRadius) {
        if (cbv.tag == cbvIn.tag) {
            cbv.checked = TRUE;
        } else {
            cbv.checked = FALSE;
        }
    }
    appDelegate.userPreferences.radiusChoice = cbvIn.tag;
    //Need to reload from API, so clear places array
    [self emptyPlacesArray];
}

- (void) checkBoxOpenNowChangedState:(SSCheckBoxView *)cbvIn
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.userPreferences.openNow = self.cbOpenNow.checked;
    //Need to reload from API, so clear places array
    [self emptyPlacesArray];
}
- (void) checkBoxRestaurantsChangedState:(SSCheckBoxView *)cbvIn
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.userPreferences.searchTypeRestaurant = self.cbRestaurants.checked;
    //Need to reload from API, so clear places array
    [self emptyPlacesArray];
}
- (void) checkBoxCafesChangedState:(SSCheckBoxView *)cbvIn
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.userPreferences.searchTypeCafe = self.cbCafes.checked;
    [self emptyPlacesArray];
}
- (void) checkBoxBarsChangedState:(SSCheckBoxView *)cbvIn
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.userPreferences.searchTypeBar = self.cbBars.checked;
    [self emptyPlacesArray];
}

- (void) viewWillAppear:(BOOL)flag
{
    [super viewWillAppear:flag];

}
- (void)viewDidDisappear:(BOOL)animated
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"options";
    NSData *myEncodedUserPreference = [NSKeyedArchiver archivedDataWithRootObject:appDelegate.userPreferences];
    [defaults setObject:myEncodedUserPreference forKey:key];

    [defaults synchronize];
    
}

- (void)viewDidLoad
{
   
    [super viewDidLoad];
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        
	// Do any additional setup after loading the view.
    
    //ActivityViewController *avc = [[ActivityViewController alloc] initWithNibName:@"ActivityViewController" bundle:nil];
    //avc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //[self.view addSubview:avc.view];
    //[self presentViewController:avc animated:NO completion:nil];

    //dispatch_queue_t loadOptions = dispatch_queue_create("optionsLoader", NULL);
    //dispatch_async(loadOptions, ^{
        
        //[NSThread sleepForTimeInterval:5.];
        
        self.cbSort = [[NSMutableArray alloc] initWithCapacity:4];
        self.cbRadius = [[NSMutableArray alloc] initWithCapacity:4];
        
        SSCheckBoxView *cbs = nil;
        CGRect frame = CGRectMake(105, 67, 21, 101);
        for (int i = -1; i < 5; ++i) {
            SSCheckBoxViewStyle style = kSSCheckBoxViewStyleBox;
            BOOL checked;
            if (appDelegate.userPreferences.sortOrder == i) {
                checked = TRUE;
            } else {
                checked = FALSE;
            }
            cbs = [[SSCheckBoxView alloc] initWithFrame:frame
                                                  style:style
                                                checked:checked];
            cbs.tag = i;
            
            [cbs setStateChangedTarget:self selector:@selector(checkBoxSortChangedState:)];
            [self.view addSubview:cbs];
            [self.cbSort addObject:cbs];
            frame.origin.y += 25;
        }
        
        frame = CGRectMake(235, 67, 21, 101);
        for (int i = 0; i < 4; ++i) {
            SSCheckBoxViewStyle style = kSSCheckBoxViewStyleBox;
            BOOL checked;
            if (appDelegate.userPreferences.radiusChoice == i) {
                checked = TRUE;
            } else {
                checked = FALSE;
            }
            cbs = [[SSCheckBoxView alloc] initWithFrame:frame
                                                  style:style
                                                checked:checked];
            cbs.tag = i;
            
            [cbs setStateChangedTarget:self selector:@selector(checkBoxRadiusChangedState:)];
            [self.view addSubview:cbs];
            [self.cbRadius addObject:cbs];
            frame.origin.y += 25;
        }
        
        //openNow
        frame = CGRectMake(105, 257, 21, 21);
        SSCheckBoxViewStyle style = kSSCheckBoxViewStyleBox;
        BOOL checked;
        if (appDelegate.userPreferences.openNow) {
            checked = TRUE;
        } else {
            checked = FALSE;
        }
        self.cbOpenNow = [[SSCheckBoxView alloc] initWithFrame:frame
                                                         style:style
                                                       checked:checked];
        
        [self.cbOpenNow setStateChangedTarget:self selector:@selector(checkBoxOpenNowChangedState:)];
        [self.view addSubview:self.cbOpenNow];
        
        //typeRestaurants
        frame = CGRectMake(105, 282, 21, 21);
        if (appDelegate.userPreferences.searchTypeRestaurant) {
            checked = TRUE;
        } else {
            checked = FALSE;
        }
        self.cbRestaurants = [[SSCheckBoxView alloc] initWithFrame:frame
                                                             style:style
                                                           checked:checked];
        
        [self.cbRestaurants setStateChangedTarget:self selector:@selector(checkBoxRestaurantsChangedState:)];
        [self.view addSubview:self.cbRestaurants];
        
        //type Cafe
        frame = CGRectMake(105, 307, 21, 21);
        if (appDelegate.userPreferences.searchTypeCafe) {
            checked = TRUE;
        } else {
            checked = FALSE;
        }
        self.cbCafes = [[SSCheckBoxView alloc] initWithFrame:frame
                                                       style:style
                                                     checked:checked];
        
        [self.cbCafes setStateChangedTarget:self selector:@selector(checkBoxCafesChangedState:)];
        [self.view addSubview:self.cbCafes];
       
        //type Bars
        frame = CGRectMake(105, 332, 21, 21);
        if (appDelegate.userPreferences.searchTypeBar) {
            checked = TRUE;
        } else {
            checked = FALSE;
        }
        self.cbBars = [[SSCheckBoxView alloc] initWithFrame:frame
                                                      style:style
                                                    checked:checked];
        
        [self.cbBars setStateChangedTarget:self selector:@selector(checkBoxBarsChangedState:)];
        [self.view addSubview:self.cbBars];
        
    
//        dispatch_async(dispatch_get_main_queue(), ^ {
            //[appDelegate.activityView stopAnimating];
//            [self dismissViewControllerAnimated:YES completion:nil];
            
//        });
//    });

    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
