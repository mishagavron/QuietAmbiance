//
//  AdvancedSearchViewController.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/23/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvancedSearchViewController : UIViewController


@property (weak) IBOutlet UISlider *slider;
@property (weak) IBOutlet UIButton *button;
@property (weak) IBOutlet UITextField *text;
@property (weak) IBOutlet UITableView *table;

- (IBAction) sliderValueChanged;
- (IBAction) searchAction;
- (IBAction) cancelAction;

@end


