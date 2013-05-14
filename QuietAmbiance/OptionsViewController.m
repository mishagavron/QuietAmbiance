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

@interface OptionsViewController ()

@end

@implementation OptionsViewController

@synthesize cbOpenNow, cbRadius, cbSort;

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
            cbv.enabled = FALSE;
            cbv.checked = TRUE;
        } else {
            cbv.enabled = TRUE;
            cbv.checked = FALSE;
        }
    }
    appDelegate.userPreferences.sortOrder = cbvIn.tag;
}

- (void) checkBoxRadiusChangedState:(SSCheckBoxView *)cbvIn
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    // toggle all
    for (SSCheckBoxView *cbv in self.cbRadius) {
        if (cbv.tag == cbvIn.tag) {
            cbv.enabled = FALSE;
            cbv.checked = TRUE;
        } else {
            cbv.enabled = TRUE;
            cbv.checked = FALSE;
        }
    }
    appDelegate.userPreferences.searchRadius = 500 * (cbvIn.tag + 1);
}

- (void) checkBoxOpenNowChangedState:(SSCheckBoxView *)cbvIn
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.userPreferences.openNow = self.cbOpenNow.checked;
    //cbvIn.checked = !cbvIn.checked;
    

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
    
	// Do any additional setup after loading the view.
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;

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
        if (checked) {[cbs setEnabled:FALSE];}
        else {[cbs setEnabled:TRUE];}
        
        [cbs setStateChangedTarget:self selector:@selector(checkBoxSortChangedState:)];
        [self.view addSubview:cbs];
        [self.cbSort addObject:cbs];
        frame.origin.y += 25;
    }

    frame = CGRectMake(235, 67, 21, 101);
    for (int i = 0; i < 4; ++i) {
        SSCheckBoxViewStyle style = kSSCheckBoxViewStyleBox;
        BOOL checked;
        if (appDelegate.userPreferences.searchRadius == 500*(i+1)) {
            checked = TRUE;
        } else {
            checked = FALSE;
        }
        cbs = [[SSCheckBoxView alloc] initWithFrame:frame
                                              style:style
                                            checked:checked];
        cbs.tag = i;
        if (checked) {[cbs setEnabled:FALSE];}
        else {[cbs setEnabled:TRUE];}
        
        [cbs setStateChangedTarget:self selector:@selector(checkBoxRadiusChangedState:)];
        [self.view addSubview:cbs];
        [self.cbRadius addObject:cbs];
        frame.origin.y += 25;
    }

    frame = CGRectMake(105, 235, 21, 21);
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

    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
