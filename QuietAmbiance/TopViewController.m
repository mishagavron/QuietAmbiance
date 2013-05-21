//
//  TopViewController.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/13/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "TopViewController.h"
#import "AppDelegate.h"

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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    //UIViewController *destView = [self navigationController];
    //UIViewController *destView = self;

    
    if ([segue.identifier isEqualToString:@"pushNearby"]) {
        
    } else if ([segue.identifier isEqualToString:@"pushRecent"]) {
        
    } else if ([segue.identifier isEqualToString:@"pushCapture"]) {
         
    } else if ([segue.identifier isEqualToString:@"pushOptions"]) {
        //[NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
    
    }
    //NSLog(@"Activity indicator is activated %d", [appDelegate.spinner isAnimating]);
}

@end
