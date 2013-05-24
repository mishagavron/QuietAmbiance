//
//  TopViewController.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/13/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "TopViewController.h"
#import "AppDelegate.h"
#import "OptionsViewController.h"


@interface TopViewController ()

@end

@implementation TopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void) viewWillAppear:(BOOL)animated {
    
      [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)backgroundThread {
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.activityView == nil) appDelegate.activityView = [[ActivityViewController alloc] initWithNibName:@"ActivityViewController" bundle:nil];
    [self presentViewController:appDelegate.activityView animated:TRUE completion:nil];
    
    //[self.navigationController pushViewController:appDelegate.activityView animated:YES];
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    

    //AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([segue.identifier isEqualToString:@"pushNearby"]) {
        
    } else if ([segue.identifier isEqualToString:@"pushRecent"]) {
        
    } else if ([segue.identifier isEqualToString:@"pushCapture"]) {
         
    } else if ([segue.identifier isEqualToString:@"pushOptions"]) {
        
    }
}

@end
