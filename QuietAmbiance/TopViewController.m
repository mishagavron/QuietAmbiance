//
//  TopViewController.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/29/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "AppDelegate.h"
#import "TopViewController.h"
#import "TopViewCell.h"
#import "NearbyListViewController.h"

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
    //[self.collectionView registerClass:[TopViewCell class] forCellWithReuseIdentifier:@"TopViewCell"];
    //[[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
     [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"NearbyPush"]){
        
        AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.locationState == Undefined) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services"
                                                            message:@"Sorry, Location Service seems to be off."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }

        TopViewCell *cell = (TopViewCell*)sender;
        NearbyListViewController *vc = (NearbyListViewController*)[segue destinationViewController];
        //[[vc navigationController] setNavigationBarHidden:NO animated:YES];
    }
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (TopViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"TopViewCell";
    TopViewCell *cell = (TopViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    //[cell setBackgroundColor:[UIColor redColor]];
    
    int imageNumber = indexPath.row % 6;
    
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"TopCellImage%d.png",imageNumber]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    //[[self navigationController] setNavigationBarHidden:YES animated:YES];
}



@end
