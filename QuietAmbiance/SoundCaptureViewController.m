//
//  SoundCaptureViewController.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/6/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "SoundCaptureViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Place.h"
#import "RecordCell.h"
#import "UserPreferences.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#include "AFImageRequestOperation.h"
#include "ResultDetailsViewController.h"

@interface SoundCaptureViewController ()

@end

@implementation SoundCaptureViewController

//@synthesize places;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    [self.tableView registerNib:[UINib nibWithNibName:@"RecordCell" bundle:nil] forCellReuseIdentifier:@"RecordCell"];
    
    //UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
    self.rowHeight = 50.0;
    [self loadPlaces];
}

-(void) viewWillAppear:(BOOL)flag {
    
    [super viewWillAppear:flag];
    
    UIAlertView *alert = nil;
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.locationState == Undefined) {
        
        alert = [[UIAlertView alloc] initWithTitle:@"Location Services"
                                           message:@"You must enable Location Services to use this app."
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
    if (([appDelegate.places count] == 0) && (appDelegate.locationState == Defined)) {
        [self loadPlaces];
        [self.tableView reloadData];
    }
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}


-(void) refreshTable:(UIRefreshControl *)refresh {
    [self loadPlaces];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    
}

- (void)loadPlaces {
    //load Nearby places content only if places array is not populated
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.places == nil) {
        appDelegate.places = [[NSMutableArray alloc] init];
    }
    
    if ([appDelegate.places count] >0) return;  // no need to reload from API
    

    CLLocation *currentLocation=appDelegate.locationManager.location;
    
    
    NSString *lat = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
    NSString *longt = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
    NSString *gKey = [Utils getKey];
    NSString *radius = [Utils getSearchRadius];
    NSString *type = [Utils getSearchType];
    
    NSString *placeString  = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?opennow&types=%@&name=&location=%@,%@&radius=%@&sensor=false&key=%@",type,lat,longt,radius,gKey];
    placeString = [UserPreferences personilizeGoogleAPIURLString:placeString];
    NSLog(@"request string: %@",placeString);
    
    NSURL *placeURL = [NSURL URLWithString:placeString];
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
        NSLog(@"Error getting %@, HTTP status code %i", placeString, [responseCode statusCode]);
        return;
    }
    
    NSDictionary *res =[NSJSONSerialization
                        JSONObjectWithData:JSON
                        options:NSJSONReadingMutableLeaves
                        error:nil];
    
    [appDelegate.places removeAllObjects];
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:appDelegate.currentLocation.lattitude longitude:appDelegate.currentLocation.longitude];
    
    int count = 0;
    for(NSDictionary *result in [res objectForKey:@"results"])
    {
        //NSDictionary *location = [[result objectForKey:@"geometry"] objectForKey:@"location"];
        Place *place = [[Place alloc] init];
        NSString *name = [result objectForKey:@"name"];
        NSString *photo_ref = @"";
        
        
        NSString *reference = [result objectForKey:@"reference"];
        NSString *rating = [result objectForKey:@"rating"];
        NSString *price_level = [result objectForKey:@"price_level"];
        NSString *icon = [result objectForKey:@"icon"];
        NSString *place_id = [result objectForKey:@"id"];
        NSString *vicinity = [result objectForKey:@"vicinity"];
        place.name = name;
        place.reference = reference;
        place.rating = rating;
        place.ratingNum = [rating doubleValue];
        place.price_level = price_level;
        place.priceNum = [price_level doubleValue];
        place.soundNum = (double)count;
        place.icon = icon;
        place.place_id = place_id;
        place.vicinity = vicinity;
        
        for (NSDictionary *photos in [result objectForKey:@"photos"]) {
            photo_ref = [photos objectForKey:@"photo_reference"];
        }
        
        
        NSDictionary *geo = [result objectForKey:@"geometry"];
        NSDictionary *locs = [geo objectForKey:@"location"];
        
        
        NSString *lat = [locs objectForKey:@"lat"];
        NSString *lng = [locs objectForKey:@"lng"];
        double latD = [lat doubleValue];
        double longtD = [lng doubleValue];
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:latD longitude:longtD];
        place.distanceNumMeters = [Utils distanceInMeters:locA To:locB];
        
        place.lattitude = lat;
        place.longitude = lng;
        
        
        place.reference_photo = photo_ref;
        
        //NSLog(@"name: %@", name);
        [appDelegate.places addObject:place];
        count++;
    }
    if (([appDelegate.places count] == 0) && (appDelegate.locationState == Defined)) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nearby Places"
                                                        message:@"Sorry, there are no Places nearby."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSInteger ret = 0;
    if (appDelegate.places != nil) {
        ret= [appDelegate.places count];
    }
    
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecordCell";
    RecordCell *cell = (RecordCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([appDelegate.places count] > 0) {
        
        Place *place = [appDelegate.places objectAtIndex:(long)indexPath.row];
        NSString *row_text = @"";
        // NSString *row_text_details = @"";
        NSString *price_level = @"";
        NSString *rating = @"";
        NSString *icon = @"";
        NSString *currency = appDelegate.currentLocation.currency;
        NSString *row_index = [NSString stringWithFormat:@"%d.", indexPath.row+1];
        row_text = [row_text stringByAppendingString:row_index];
        row_text = [row_text stringByAppendingString:place.name];
        price_level = [Utils mapPriceToString:[place.price_level integerValue] UsingCurrency:currency];
        rating = [Utils mapRatingToString:[place.rating doubleValue]];
        UIImage *rating_img = [Utils mapRatingToImage:[place.rating doubleValue]];
        UIImage *no_photo = [UIImage imageNamed:@"no_photos.png"];
        icon = place.icon;
        if ([icon rangeOfString:@"bar"].location != NSNotFound) {
            icon = @"bar.png";
        } else if ([icon rangeOfString:@"cafe"].location != NSNotFound) {
            icon = @"cafe.png";
        } else if ([icon rangeOfString:@"restaurant"].location != NSNotFound) {
            icon = @"restaurant.png";
        }
        else {
            icon = @"establishment.png";
        }
        UIImage *icon_img = [UIImage imageNamed:icon];
        if (place.iPhoto == nil) {
            // download the photo
            if ([place.reference_photo length] != 0) {
                NSString *gKey = [Utils getKey];
                NSString *height = [NSString stringWithFormat:@"%d",(int)self.rowHeight];
            
                NSString *placeString  = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=%@&photoreference=%@&sensor=false&key=%@",height,place.reference_photo,gKey];
                //NSLog(@"request string: %@",placeString);
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:placeString]];
                AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
                
                
                // MyManagedObject has a custom setters (setPhoto:,setThumb:) that save the
                // images to disk and store the file path in the database
                cell.rPhoto.image = image;
                place.iPhoto = image;
                }];
                [operation start];
                }
                else {
                    cell.rPhoto.image = no_photo;
                    place.iPhoto = no_photo;
                }
        } else {
            cell.rPhoto.image = place.iPhoto;
        }
        
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:appDelegate.currentLocation.lattitude longitude:appDelegate.currentLocation.longitude];
        double lat = [place.lattitude doubleValue];
        double longt = [place.longitude doubleValue];
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:lat longitude:longt];
        cell.rDistance.text = [Utils distanceString:locA To:locB];
        
        place.iRating = rating_img;
        place.price_level = price_level;
        //place.iSound =
        cell.rRating.image = rating_img;
        cell.rPriceLevel.text = price_level;
        cell.rIcon.image  = icon_img;
        cell.rName.text = row_text;
        cell.rVicinity.text = place.vicinity;
        //cell.rSoundLevel
        
        UIImage *image = [UIImage imageNamed:@"record.png"]; //or wherever you take your image from
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        cell.accessoryView = imageView;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    Place *p = [appDelegate.places objectAtIndex:indexPath.row];
    p.iSound = nil;
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
  	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
  	NSError *error;
    
  	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
  	if (recorder) {
  		[recorder prepareToRecord];
  		recorder.meteringEnabled = YES;
  		[recorder record];
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView = spinner;
        [spinner startAnimating];
        
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
        
        [NSTimer scheduledTimerWithTimeInterval:5 target: self selector: @selector(stopSampling:) userInfo:p.place_id repeats: NO];
        
  	} else
  		NSLog([error description]);
	
	/*
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Custom Button Pressed"
     message:[NSString stringWithFormat: @"You pressed the custom button on cell #%i", pathToCell.row + 1]
     delegate:self cancelButtonTitle:@"Great"
     otherButtonTitles:nil];
     */
    
}

- (void)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
}

-(void)stopSampling:(NSTimer*)timer {
    [levelTimer invalidate];

    NSURL *baseURL = [NSURL URLWithString:@"http://upbeat.azurewebsites.net/api/soundsamples"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [httpClient defaultValueForHeader:@"Accept"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [timer userInfo], @"googleid", [NSString stringWithFormat:@"%f", avgSound], @"soundsample", nil];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:@"http://upbeat.azurewebsites.net/api/soundsamples/postsoundsamplewithgoogleid" parameters:params];
    
    //Add your request object to an AFHTTPRequestOperation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation,
       id responseObject) {
         NSString *response = [operation responseString];
         NSLog(@"response: [%@]",response);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"error: %@", [operation error]);
     }];
    
    //call start on your request operation
    [operation start];
    
    [spinner stopAnimating];
    
}

- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];
	avgSound = [recorder averagePowerForChannel:0];
    NSLog(@"Average input: %f Peak input: %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0]);
}

@end
