//
//  MessageViewController.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/7/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "MessageViewController.h"

@interface MessageViewController ()

@end

@implementation MessageViewController

@synthesize messageText;

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
    self.messageLabel.text = self.messageText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMessage:(NSString*) message {
    self.messageText = message;
}

- (void) viewWillAppear:(BOOL)flag {
    
    [super viewWillAppear:flag];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction) dismiss:(id) sender {
    // Dismiss the view
    [self.view setHidden:YES];
    UINavigationController* navController = self.navigationController;
    UIViewController* topView = [navController.viewControllers objectAtIndex:0];
    [[topView navigationController] setNavigationBarHidden:YES animated:YES];
    [navController popToViewController:topView animated:YES];
    
}

@end
