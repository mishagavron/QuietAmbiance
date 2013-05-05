//
//  Review.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/25/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Review : NSObject

@property (strong) NSString *text;
@property (strong) NSString *author;
@property (strong) NSString *authorUrl;
@property (strong) NSDate *time;
@property (strong) NSString *authorId;
@property (strong) UIImage *authorPic;

//this is a total heck
@property (strong) NSString *picRequestReturn;


@end
