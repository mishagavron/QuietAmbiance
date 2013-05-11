//
//  SearchViewController.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 5/6/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"
#import "SearchCell.h"
#import "ResultDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "UserPreferences.h"
#import "MessageViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize searchResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadPlaces {
    
}

- (IBAction)sortOrderChanged {
    
}

-(void) viewWillAppear:(BOOL)flag {
    
    [super viewWillAppear:flag];
    
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchCell" bundle:nil] forCellReuseIdentifier:@"SearchCell"];
 
    CALayer *layer = self.tableView.layer;
    layer.borderWidth = 1;
    layer.borderColor = [[UIColor grayColor] CGColor];
    layer.cornerRadius = 10;
    layer.masksToBounds = YES;
    
    self.searchBar.text = @"";
    self.searchResults = [[NSMutableArray alloc] init];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //clear cell values
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	//[self filterContent:clickedSearchBar.text];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.text = nil;
	[searchBar resignFirstResponder];
	
	[self filterContent:searchBar.text];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self filterContent:searchText];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	//inSearchMode = true;
	//[searchBar setShowsCancelButton:inSearchMode animated:true];
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	NSString *searchText = searchBar.text;
    //NSLog((@"Keyboard entry %d", searchText));
    [self.searchResults removeAllObjects];
    
	
	// We're still 'in edit mode', if the user left a keyword in the searchBar
	//inSearchMode = (searchText != nil && [searchText length] > 0);
	//[searchBar setShowsCancelButton:inSearchMode animated:true];
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSString *lat = [NSString stringWithFormat:@"%f", appDelegate.currentLocation.lattitude];
    NSString *longt = [NSString stringWithFormat:@"%f", appDelegate.currentLocation.longitude];
    NSString *gKey = [Utils getKey];
    NSString *radius = [Utils getSearchRadius];
    NSString *type = [Utils getSearchType];
    
    NSString *placeString  = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/xml?query=%@&types=%@&location=%@,%@&radius=%@&sensor=false&key=%@",searchText,type,lat,longt,radius,gKey];
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
        
        MessageViewController *msgc = [[MessageViewController alloc] initWithNibName:@"MessageViewController" bundle:nil];
        [msgc setMessage:@"Sorry, nothing found."];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController pushViewController:msgc animated:YES];
        return;
    }
    
    if ([appDelegate.places count] > 0) {
        [self sortOrderChanged];
    }

	
	[self filterContent:searchText];
}


- (void)filterContent:(NSString*)searchText
{

}


#pragma Table stuff

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchCell";
    SearchCell *cell = (SearchCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = 1;

    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;

    
    
    ResultDetailsViewController *rvc = [[ResultDetailsViewController alloc] initWithNibName:@"ResultDetailsViewController" bundle:nil];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self.navigationController pushViewController:rvc animated:YES];
    

}

- (void)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
}

@end
