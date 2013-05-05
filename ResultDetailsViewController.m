//
//  ResultDetailsViewController.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ResultDetailsViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Review.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#include "AFImageRequestOperation.h"
#include "ReviewCell.h"

@interface ResultDetailsViewController ()

@end

@implementation ResultDetailsViewController

@synthesize place,placeDetail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)mapItSelected:(id)sender {
    
    Class itemClass = [MKMapItem class];
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;

    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        // iOS 6 MKMapItem available
        CLLocationCoordinate2D To;
        To.latitude = [place.lattitude doubleValue];
        To.longitude = [place.longitude doubleValue];
        MKPlacemark* pl = [[MKPlacemark alloc] initWithCoordinate: To addressDictionary: nil];
        MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: pl];
        destination.name = placeDetail.address;
        NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
        NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 MKLaunchOptionsDirectionsModeWalking,
                                 MKLaunchOptionsDirectionsModeKey, nil];
        [MKMapItem openMapsWithItems: items launchOptions: options];
    } else {
        // use pre iOS 6 technique
        CLLocationCoordinate2D currentLocation = appDelegate.locationManager.location.coordinate;
        // this uses an address for the destination.  can use lat/long, too with %f,%f format
        NSString* address = placeDetail.address;
        NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%@",
                         currentLocation.latitude, currentLocation.longitude,
                         [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

- (IBAction)callItSelected:(id)sender {
    
    NSString *phoneNumber = [@"tel://" stringByAppendingString:placeDetail.phone];
    NSLog(@"Phone call string: %@",phoneNumber);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"ReviewCell" bundle:nil] forCellReuseIdentifier:@"ReviewCell"];
    
    //load Nearby places content
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;

    NSString *gKey = [Utils getKey];
    NSString *placeDetailsString  = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=false&key=%@",self.place.reference,gKey];
    NSLog(@"request string: %@",placeDetailsString);
    
    NSURL *placeURL = [NSURL URLWithString:placeDetailsString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setHTTPMethod:@"GET"];
    [request setURL:placeURL];
    //NSURLResponse* response;
    //NSError* error = nil;
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    NSData *JSON;
    JSON = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", placeDetailsString, [responseCode statusCode]);
        return;
    }
    
    NSDictionary *res =[NSJSONSerialization
                        JSONObjectWithData:JSON
                        options:NSJSONReadingMutableLeaves
                        error:nil];
    
    
    NSDictionary *resDict = [res objectForKey:@"result"];
    {
        self.placeDetail = [[PlaceDetails alloc] init];
        NSString *address = [resDict objectForKey:@"formatted_address"];
        NSString *phone = [resDict objectForKey:@"formatted_phone_number"];
        NSString *review_text =@"";
        NSString *review_author =@"";
        NSString *review_authorURL =@"";
        NSString *review_time =@"";

        if (self.placeDetail.reviews == nil) {
            self.placeDetail.reviews = [[NSMutableArray alloc] init];
        } else {
            [self.placeDetail.reviews removeAllObjects];
        }
        for (NSDictionary *reviews in [resDict objectForKey:@"reviews"]) {
            Review *review = [[Review alloc] init];
            review_text = [reviews objectForKey:@"text"];
            review_authorURL = [reviews objectForKey:@"author_url"];
            review_author = [reviews objectForKey:@"author_name"];
            review_time = [reviews objectForKey:@"time"];
            review.text = review_text;
            review.authorUrl = review_authorURL;
            review.author = review_author;
            // Convert NSString to NSTimeInterval
            NSTimeInterval seconds = [review_time doubleValue];
            NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
            review.time = epochNSDate;
            review.authorId = @"";
            //find user_id
            NSArray *urlComponents = [review_authorURL componentsSeparatedByString:@"/"];
            if (urlComponents != nil && [urlComponents count] > 3) {
                review.authorId = [urlComponents objectAtIndex:3];
            }
            [self.placeDetail.reviews addObject:review];
            
        }
     
        //sort reviews by date
       // NSLog(@"Reviews count before sort: %lu",(unsigned long)[self.placeDetail.reviews count]);

        NSSortDescriptor *highToLow = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
        NSArray *mySortDescriptors = [NSArray arrayWithObject:highToLow];
        NSArray *sortedArray = [self.placeDetail.reviews sortedArrayUsingDescriptors:mySortDescriptors];
        self.placeDetail.reviews = [sortedArray mutableCopy];
        
        self.placeDetail.phone = phone;
        self.placeDetail.address =  address;
        
        //adjust scroll view based on a number of reviews
 
    }
    
    //NSLog(@"Reviews count after sort: %lu",(unsigned long)[self.placeDetail.reviews count]);
    
    self.lName.text = self.place.name;
    self.lAddress.text = self.placeDetail.address;
    self.lPriceLevel.text = self.place.price_level;
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:appDelegate.currentLocation.lattitude longitude:appDelegate.currentLocation.longitude];
    double lat = [self.place.lattitude doubleValue];
    double longt = [self.place.longitude doubleValue];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:lat longitude:longt];
    self.lDistance.text = [Utils distanceString:locA To:locB];
    
    if ([self.placeDetail.reviews count] > 0) {
        NSString *numRevues = [NSString stringWithFormat:@"%d Reviews",[self.placeDetail.reviews count]];
        self.lReviewsNum.text = numRevues;
    } else {
        self.lReviewsNum.text = @"No Reviews";
    }
    self.iPhoto.image = self.place.iPhoto;
    self.iRating.image = self.place.iRating;
    //self.tableView.contentSize = CGSizeMake(320,325 + 125*[self.placeDetail.reviews count]);
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y,self.tableView.frame.size.width,325 + 125*[self.placeDetail.reviews count]);

    self.scrollView.contentSize=CGSizeMake(320,325 + 125*[self.placeDetail.reviews count]);
    [self.scrollView setContentSize:(CGSizeMake(320, 325 + 125*[self.placeDetail.reviews count]))];
 }

#pragma mark - Table view data source

/*
- (CGRect)rectForSection:(NSInteger)section {
    CGRect ret = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y,
               self.tableView.frame.size.width,  325 + 125*[self.placeDetail.reviews count]);
    return ret;
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect ret = CGRectMake(0, 0,
                            self.tableView.frame.size.width, 125);
    return ret;
}
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = 0;
    if (self.placeDetail.reviews != nil) {
        ret= [self.placeDetail.reviews count];
    }
    
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125.;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReviewCell";
    ReviewCell *cell = (ReviewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //fill in the display
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM-dd-yyyy"];
    //NSLog(@"Reviews count: %lu",(unsigned long)[self.placeDetail.reviews count]);

    if ([self.placeDetail.reviews count] > 0) {
        Review *review = [self.placeDetail.reviews objectAtIndex:(long)indexPath.row];
        cell.authorName.text = review.author;
        cell.reviewTime.text = [formatter stringFromDate:review.time];
        cell.reviewText.text = [Utils convertEscapeTexttoPlainText:review.text];
        
        UIImage *noAuthorPic = [UIImage imageNamed:@"no_author_pic.png"];
        review.authorPic = noAuthorPic;
        cell.authorPic.image = noAuthorPic;
        if (![review.authorId isEqual: @""]) {
            //NSString *gKey = [Utils getKey];
            NSString *authorPic  = [NSString stringWithFormat:@"https://plus.google.com/s2/photos/profile/%@?sz=30",review.authorId];
            //NSLog(@"request pics string: %@",authorPic);
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authorPic]];

                AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                    {
                        //NSLog(@"Successful pic request for author: %@",cell.authorName.text);
                        //NSLog(@"With Request: %@",authorPic);
                        review.authorPic = image;
                        cell.authorPic.image = image;
                    }
                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                    {
                        //NSLog(@"Failed pic request for author: %@",cell.authorName.text);
                        //NSLog(@"With Request: %@",authorPic);
                        review.authorPic = noAuthorPic;
                        cell.authorPic.image = noAuthorPic;
                    }
                    ];

                [operation start];

            }
            else {
                review.authorPic = noAuthorPic;
                cell.authorPic.image = noAuthorPic;
            }
        }
    

    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
}

- (void)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
}



- (void)viewWillDisappear:(BOOL)flag {
    //[[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
