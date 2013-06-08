//
//  SoundCaptureViewController.h
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/6/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface SoundCaptureViewController : UITableViewController {
    AVAudioRecorder *recorder;
    NSTimer *levelTimer;
    double avgSound;
    
    UIActivityIndicatorView *spinner;
    UIImageView *activityImageView;
}

- (void)levelTimerCallback:(NSTimer *)timer;

//@property (strong) NSMutableArray *places;

@property double rowHeight;

- (void)loadPlaces;
- (void)refreshTable:(UIRefreshControl *)refresh;

- (void)sortByDistance;

@end
