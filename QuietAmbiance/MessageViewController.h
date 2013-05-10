//
//  MessageViewController.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/7/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageViewController : UIViewController

- (IBAction) dismiss:(id) sender;
    
- (void)setMessage:(NSString*) message;

@property (strong) NSString* messageText;

@property (weak) IBOutlet UILabel *messageLabel;
@property (weak)IBOutlet UIButton *messageButton;
    

@end
