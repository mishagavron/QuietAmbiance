//
//  SearchCell.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/9/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCell : UITableViewCell
@property (weak)IBOutlet UILabel *rName;
@property (weak)IBOutlet UILabel *rPriceLevel;
@property (weak)IBOutlet UILabel *rDistance;
@property (weak)IBOutlet UIImageView *rSoundLevel;
@property (weak)IBOutlet UILabel *rVicinity;
@property (weak)IBOutlet UIImageView *rPhoto;
@property (weak)IBOutlet UIImageView *rIcon;
@property (weak)IBOutlet UIImageView *rRating;

@end
