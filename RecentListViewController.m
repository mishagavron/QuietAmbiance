//
//  RecentListViewController.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "RecentListViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Place.h"
#import "ResultCell.h"
#import "UserPreferences.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#include "AFImageRequestOperation.h"
#include "ResultDetailsViewController.h"
#include "ActivityViewController.h"

@interface RecentListViewController ()

@end

@implementation RecentListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ResultCell" bundle:nil] forCellReuseIdentifier:@"ResultCell"];
    //AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    //UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
    self.rowHeight = 80.0;
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    ActivityViewController *avc = [[ActivityViewController alloc] initWithNibName:@"ActivityViewController" bundle:nil];
    avc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.view addSubview:avc.view];
    [self presentViewController:avc animated:NO completion:nil];
    
    dispatch_queue_t loadOptions = dispatch_queue_create("optionsLoader", NULL);
    dispatch_async(loadOptions, ^{
        [self loadPlaces];
        [self.tableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            //[appDelegate.activityView stopAnimating];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)loadPlaces {

    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.recentPlaces = [[NSMutableArray alloc] init];
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:appDelegate.currentLocation.lattitude longitude:appDelegate.currentLocation.longitude];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = @"recentlist";
    recentList = [defaults stringArrayForKey:key];
    
    for(NSString *recentPlace in recentList)
    {
        NSString *gKey = [Utils getKey];
        NSString *placeDetailsString  = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=false&key=%@",recentPlace,gKey];
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
        }
        
        NSDictionary *res =[NSJSONSerialization
                            JSONObjectWithData:JSON
                            options:NSJSONReadingMutableLeaves
                            error:nil];
        
        
        int count = 0;
        NSDictionary *result = [res objectForKey:@"result"];
        {
            Place *place = [[Place alloc] init];
            
            //NSDictionary *location = [[result objectForKey:@"geometry"] objectForKey:@"location"];
            
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
            NSDictionary *geometry = [result objectForKey:@"geometry"];
            if (geometry != nil) {
                NSDictionary *placeLoc = [geometry objectForKey:@"location"];
                NSString *lat = [placeLoc objectForKey:@"lat"];
                NSString *lng = [placeLoc  objectForKey:@"lng"];
                double latD = [lat doubleValue];
                double longtD = [lng doubleValue];
                CLLocation *locB = [[CLLocation alloc] initWithLatitude:latD longitude:longtD];
                place.distanceNumMeters = [Utils distanceInMeters:locA To:locB];
                
                place.lattitude = lat;
                place.longitude = lng;
            }
            
            for (NSDictionary *photos in [result objectForKey:@"photos"]) {
                photo_ref = [photos objectForKey:@"photo_reference"];
            }
            
            place.reference_photo = photo_ref;
            [appDelegate.recentPlaces addObject:place];
            count++;
        }
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return [recentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ResultCell";
    ResultCell *cell = (ResultCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([appDelegate.recentPlaces count] > 0) {
        
        Place *place = [appDelegate.recentPlaces objectAtIndex:(long)indexPath.row];

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
                NSString *height = [NSString stringWithFormat:@"%u",(int)cell.frame.size.height];
                
                NSString *placeString  = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=%@&maxheight=%@&photoreference=%@&sensor=false&key=%@",height,height,place.reference_photo,gKey];
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
        
        //load Shishes
        if (place.iSound == nil) {
            NSString *placeString  = [NSString stringWithFormat:@"http://upbeat.azurewebsites.net/api/beats/getbeatbygoogleid/%@",place.place_id];
            //NSLog(@"request string: %@",placeString);
            
            NSURL *placeURL = [NSURL URLWithString:placeString];
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:placeURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
            [request setHTTPMethod:@"GET"];
            
            AFJSONRequestOperation *operation = [ AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                //NSLog(@"IP Address: %@", [JSON valueForKeyPath:@"origin"]);
                NSLog(@"connectionDidFinishLoading");
                
                NSLog(@"%@", JSON);
                
                // convert to JSON
                NSError *myError = nil;
                NSString *sound_level = @"";
                
                //NSDictionary *res = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves     error:&myError];
                NSDictionary *res = (NSDictionary *) JSON;
                NSLog(@"error : %@", myError);
                
                NSString *sampleavg = [res objectForKey:@"SampleAvg"];
                
                NSLog(@"sampleavg: %@", sampleavg);
                
                UIImage *ambiance_img = [Utils mapAmbianceToImage:[sampleavg doubleValue]];
                
                place.iSound = ambiance_img;
                cell.rSoundLevel.image = ambiance_img;
                
                //NSString *beatid = [res valueForKeyPath:@"Beat.BeatId"];
                
                //NSLog(@"beatid: %@", beatid);
                
                for(NSDictionary *sndresult in [res valueForKeyPath:@"Beat.SoundSamples"]){
                    sound_level = [sndresult objectForKey:@"SoundLevel"];
                    
                    NSLog(@"soundlevel: %@", sound_level);
                    
                    //NSLog(@"BeatId: %@", [result objectForKey:@"BeatId"]);
                }
                
                //[self.myTableView reloadData];
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
                place.iSound = [UIImage imageNamed:@"shh_not_available.png"];
            }];
            
            
            [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:nil];
            [operation start];
        }
        cell.rSoundLevel.image = place.iSound;
        
        //[self.tableView reloadData];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    Place *p = [appDelegate.recentPlaces objectAtIndex:indexPath.row];
    
    
    ResultDetailsViewController *rvc = [[ResultDetailsViewController alloc] initWithNibName:@"ResultDetailsViewController" bundle:nil];
    rvc.place = p;
    rvc.place.iPhoto = [UIImage imageWithData:UIImagePNGRepresentation(p.iPhoto)];
    //AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    //[[NSBundle mainBundle] loadNibNamed:@"ResultDetailsViewController" owner:self options:nil];
 
    [self.navigationController pushViewController:rvc animated:YES];
}

@end
