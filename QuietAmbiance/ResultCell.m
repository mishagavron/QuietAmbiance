//
//  ResultCell.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/22/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "ResultCell.h"

@implementation ResultCell

@synthesize rIcon, rName, rPhoto, rPriceLevel, rSoundLevel ;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
