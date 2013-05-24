//
//  NearbyListViewController.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "NearbyListViewController.h"
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
#include "MessageViewController.h"
#include "ActivityViewController.h"

@interface NearbyListViewController ()

@end


@implementation NearbyListViewController

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

    //[NSThread sleepForTimeInterval:5.0];
    self.rowHeight = 80.0;
    
    ActivityViewController *avc = [[ActivityViewController alloc] initWithNibName:@"ActivityViewController" bundle:nil];
    
    [self.view addSubview:avc.view];
    [self presentViewController:avc animated:NO completion:nil];
    
    dispatch_queue_t loadOptions = dispatch_queue_create("optionsLoader", NULL);
    dispatch_async(loadOptions, ^{

        //[NSThread sleepForTimeInterval:5.];
        [self loadPlaces];
        [self.tableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            //[appDelegate.activityView stopAnimating];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}


-(void) viewWillAppear:(BOOL)flag {
    
    [super viewWillAppear:flag];
    
    //AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
 
    //if (([appDelegate.places count] == 0) && (appDelegate.locationState == Defined)) {
    //    [self loadPlaces];
        
    //}
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}


-(void) refreshTable:(UIRefreshControl *)refresh {
  
/*
    ActivityViewController *avc = [[ActivityViewController alloc] initWithNibName:@"ActivityViewController" bundle:nil];
    
    [self.view addSubview:avc.view];
    [self presentViewController:avc animated:NO completion:nil];
    
    dispatch_queue_t loadOptions = dispatch_queue_create("optionsLoader", NULL);
    dispatch_async(loadOptions, ^{
        AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.places removeAllObjects];
*/
        [self loadPlaces];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
/*
        dispatch_async(dispatch_get_main_queue(), ^ {
            //[appDelegate.activityView stopAnimating];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
*/
}

- (void)loadPlaces {
    //load Nearby places content only if places array is not populated
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.places == nil) {
        appDelegate.places = [[NSMutableArray alloc] init];
    }
    
    if (appDelegate.locationState == Undefined) {
        
        MessageViewController *msgc = [[MessageViewController alloc] initWithNibName:@"MessageViewController" bundle:nil];
        [msgc setMessage:@"You must enable Location Services to use this app."];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController pushViewController:msgc animated:YES];
        
        [appDelegate.locationManager stopUpdatingLocation];
        [appDelegate.locationManager startUpdatingLocation];
        return;
        
    }
    CLLocation *currentLocation=appDelegate.locationManager.location;
    
    if ([appDelegate.places count] == 0) {  // reload from API only when necessary
    
        
        NSString *lat = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
        NSString *longt = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
        NSString *gKey = [Utils getKey];
        //NSString *radius = [Utils getSearchRadius];
        //NSString *type = [Utils getSearchType];
        
        NSString *placeString  = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&sensor=false&key=%@",lat,longt,gKey];
        
        placeString = [appDelegate.userPreferences personilizeGoogleAPIURLString:placeString];
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
    }
    
    if (([appDelegate.places count] == 0) && (appDelegate.locationState == Defined)) {
        
        MessageViewController *msgc = [[MessageViewController alloc] initWithNibName:@"MessageViewController" bundle:nil];
        [msgc setMessage:@"Sorry, no nearby places are found."];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController pushViewController:msgc animated:YES];
        return;
    }
    
    if ([appDelegate.places count] > 0) {
        self.sortControl.selectedSegmentIndex = appDelegate.userPreferences.sortOrder;
        [self sortOrderChanged];
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
    NSInteger ret = 0;
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.places != nil) {
        ret= [appDelegate.places count];
    }
    
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}

-(IBAction) sortOrderChanged{
    
    if (self.sortControl.selectedSegmentIndex <0) return;
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *mySortDescriptors = nil;
    if (self.sortControl.selectedSegmentIndex == 0) { //Quiet
        
        NSSortDescriptor *highToLow = [[NSSortDescriptor alloc] initWithKey:@"soundNum"
                                                                  ascending:YES];
        mySortDescriptors = [NSArray arrayWithObject:highToLow];

    }
    else if (self.sortControl.selectedSegmentIndex == 1){ //Distance
        
        NSSortDescriptor *highToLow = [[NSSortDescriptor alloc] initWithKey:@"distanceNumMeters"
                                                                  ascending:YES];
        mySortDescriptors = [NSArray arrayWithObject:highToLow];

    }
    else if (self.sortControl.selectedSegmentIndex == 2){ //Rating
        
        NSSortDescriptor *highToLow = [[NSSortDescriptor alloc] initWithKey:@"ratingNum"
                                                                  ascending:NO];
        mySortDescriptors = [NSArray arrayWithObject:highToLow];

    }
    else if (self.sortControl.selectedSegmentIndex == 3){ //Price
        NSSortDescriptor *highToLow = [[NSSortDescriptor alloc] initWithKey:@"priceNum"
                                                                  ascending:YES];
        mySortDescriptors = [NSArray arrayWithObject:highToLow];

    }
    else if (self.sortControl.selectedSegmentIndex == 4){ //Name
        NSSortDescriptor *highToLow = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                  ascending:YES];
        mySortDescriptors = [NSArray arrayWithObject:highToLow];
        
    }

    NSArray *sortedArray = [appDelegate.places sortedArrayUsingDescriptors:mySortDescriptors];
    appDelegate.places = [sortedArray mutableCopy];
    [self.tableView reloadData];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ResultCell";
    ResultCell *cell = (ResultCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
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
         price_level = [Utils mapPriceToString:(NSInteger)place.priceNum UsingCurrency:currency];
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
                NSString *height = [NSString stringWithFormat:@"%u", (int)cell.frame.size.height];
            
                NSString *placeString  = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=%@&maxheight=%@&photoreference=%@&sensor=false&key=%@",height,height,place.reference_photo,gKey];
                NSLog(@"request string: %@",placeString);
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
                place.soundNum = [sampleavg doubleValue];
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

    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    Place *p = [appDelegate.places objectAtIndex:indexPath.row];
    
    
    ResultDetailsViewController *rvc = [[ResultDetailsViewController alloc] initWithNibName:@"ResultDetailsViewController" bundle:nil];
    rvc.place = p;
    rvc.place.iPhoto = [UIImage imageWithData:UIImagePNGRepresentation(p.iPhoto)];
    //AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    //[[NSBundle mainBundle] loadNibNamed:@"ResultDetailsViewController" owner:self options:nil];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self.navigationController pushViewController:rvc animated:YES];
    
    //Save to Recent List
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = @"recentlist";
    
    NSArray *oldrecentList = [defaults stringArrayForKey:key];
    
    BOOL placeFound = FALSE;
    for (NSString *refPlace in oldrecentList) {
        if ([refPlace isEqualToString:p.reference]) {
            placeFound = TRUE;
        }
    }
    
    if (placeFound == FALSE) {
        NSMutableArray *recentlist = [[NSMutableArray alloc] initWithArray:oldrecentList];
        
        [recentlist addObject:p.reference];
        
        if ([recentlist count] > 10)
        {
            [recentlist removeObjectAtIndex:0];
        }
        
        NSArray *value = recentlist;
        
        [defaults setObject:value forKey:key];
        [defaults synchronize];
    }

}

- (void)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
}


@end
