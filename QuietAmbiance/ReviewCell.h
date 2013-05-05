//
//  ReviewCell.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/3/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewCell : UITableViewCell

@property (weak)IBOutlet UILabel *authorName;
@property (weak)IBOutlet UILabel *reviewTime;
@property (weak)IBOutlet UITextView *reviewText;
@property (weak)IBOutlet UIImageView *authorPic;

@end
