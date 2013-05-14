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
#import "SearchPhraseCell.h"
#import "ResultDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "UserPreferences.h"
#import "MessageViewController.h"
#import "SSCheckBoxView.h"
#import "AFImageRequestOperation.h" 
#import "AFJSONRequestOperation.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize searchResults, searchText;

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


-(void) viewWillAppear:(BOOL)flag {
    
    [super viewWillAppear:flag];
    
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void) checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    NSLog(@"checkBoxViewChangedState: %d", cbv.checked);
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchCell" bundle:nil] forCellReuseIdentifier:@"SearchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchPhraseCell" bundle:nil] forCellReuseIdentifier:@"SearchPhraseCell"];
    
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    self.rowHeight = 80.;
    self.searchBar.text = @"";
    self.searchResults = [[NSMutableArray alloc] init];
    self.sortControl.selectedSegmentIndex = appDelegate.userPreferences.sortOrder;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = @"recentsearch";
    
    if ([[defaults stringArrayForKey:key] count] > 0) {
        
        appDelegate.recentSearches = [NSMutableArray arrayWithArray:[defaults stringArrayForKey:key]];
    } else {
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    
    //CALayer *layer = self.tableView.layer;
    //layer.borderWidth = 1;
    //layer.borderColor = [[UIColor grayColor] CGColor];
    //layer.cornerRadius = 10;
    //layer.masksToBounds = YES;
        
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    /*
    CGRect frame = CGRectMake(5, 58, 20, 20);
    BOOL checked = TRUE;
    self.checkBox = [[SSCheckBoxView alloc] initWithFrame:frame
                                                style:kSSCheckBoxViewStyleGlossy
                                                checked:checked];
    
    [self.checkBox setStateChangedTarget:self
                                selector:@selector(checkBoxViewChangedState:)];
    
    [self.myView addSubview:self.checkBox];
     */
    
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
    
    if (![self.searchText isEqualToString:searchBar.text]){
        
        // We're still 'in edit mode', if the user left a keyword in the searchBar
        //inSearchMode = (searchText != nil && [searchText length] > 0);
        //[searchBar setShowsCancelButton:inSearchMode animated:true];
        AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;

        
        NSString *lat = [NSString stringWithFormat:@"%f", appDelegate.currentLocation.lattitude];
        NSString *longt = [NSString stringWithFormat:@"%f", appDelegate.currentLocation.longitude];
        NSString *gKey = [Utils getKey];
        //NSString *radius = [Utils getTextSearchRadius];
        //NSString *type = [Utils getSearchType];
        
        self.searchText = searchBar.text;
        NSString *placeString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&location=%@,%@&sensor=false&key=%@",self.searchText,lat,longt,gKey];
        
    
        placeString = [appDelegate.userPreferences personilizeGoogleAPIURLString:placeString];
        //placeString = [Utils personilizeGoogleAPIURLString:placeString];
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
        [self.searchResults removeAllObjects];
       
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
            NSString *vicinity = [result objectForKey:@"formatted_address"];
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
            [self.searchResults addObject:place];
            count++;
        }
        if (([self.searchResults count] == 0) && (appDelegate.locationState == Defined)) {
            
            MessageViewController *msgc = [[MessageViewController alloc] initWithNibName:@"MessageViewController" bundle:nil];
            [msgc setMessage:@"Sorry, nothing found."];
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [self.navigationController pushViewController:msgc animated:YES];
            return;
        }
        
        if ([self.searchResults count] > 0) {
            self.sortControl.selectedSegmentIndex = appDelegate.userPreferences.sortOrder;
            [self sortOrderChanged];
        }
        
        //Save to Recent Search List
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *key = @"recentsearch";
        
        NSArray *oldrecentList = [defaults stringArrayForKey:key];
        appDelegate.recentSearches = [[NSMutableArray alloc] initWithArray:oldrecentList];
        
        BOOL strFound = FALSE;
        for (NSString *str in appDelegate.recentSearches) {
            if ([str isEqualToString:self.searchText]) {
                strFound = TRUE;
            }
        }
        
        if (strFound == FALSE) { [appDelegate.recentSearches addObject:self.searchText]; }
        
        if ([appDelegate.recentSearches count] > 12)
        {
            [appDelegate.recentSearches removeObjectAtIndex:0];
        }
        
        NSArray *value = appDelegate.recentSearches;
        
        [defaults setObject:value forKey:key];
        [defaults synchronize];

 	}
    
	//[self filterContent:searchText];
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
	//[self filterContent:searchText];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	//inSearchMode = true;
	//[searchBar setShowsCancelButton:inSearchMode animated:true];
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{

}


- (void)filterContent:(NSString*)searchText
{

}


#pragma Table stuff

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    UITableViewCell *retCell = nil;
    
    if ([self.searchResults count] > 0) {
        
        static NSString *CellIdentifier = @"SearchCell";
        SearchCell *cell = (SearchCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Place *place = [self.searchResults objectAtIndex:(long)indexPath.row];
        
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
        retCell = cell;
        //[self.tableView reloadData];
    } else {
        static NSString *CellIdentifier = @"SearchPhraseCell";
        SearchPhraseCell *cell = (SearchPhraseCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSString *phrase = [appDelegate.recentSearches objectAtIndex:(long)indexPath.row];
        cell.phrase.text = phrase;
        retCell= cell;
    }
    UIView *myBackView = [[UIView alloc] initWithFrame:retCell.frame];
    myBackView.backgroundColor = [UIColor lightGrayColor];
    retCell.selectedBackgroundView = myBackView;

    return retCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSInteger ret = 0;

    if ([self.searchResults count] > 0) {
        ret = [self.searchResults count];
    } else if ([appDelegate.recentSearches count]> 0) {
        ret = [appDelegate.recentSearches count];
    }
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CGFloat ret= 0.0;
    if ([self.searchResults count] > 0) {
        ret = self.rowHeight;
    } else {
        ret = 30.0;
    }
    return ret;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([self.searchResults count] > 0) {
        
        ResultDetailsViewController *rvc = [[ResultDetailsViewController alloc] initWithNibName:@"ResultDetailsViewController" bundle:nil];
        
        Place *p = [self.searchResults objectAtIndex:indexPath.row];
        rvc.place = p;
        rvc.place.iPhoto = [UIImage imageWithData:UIImagePNGRepresentation(p.iPhoto)];

        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        
        //Save to Recent List
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [self.navigationController pushViewController:rvc animated:YES];
        
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
        
 
    } else if ([appDelegate.recentSearches count] > 0) {
        NSString *phrase = [appDelegate.recentSearches objectAtIndex:(long)indexPath.row];
        self.searchBar.text = phrase;
        [self searchBarSearchButtonClicked:self.searchBar];
        //[self didDeselectRowAtIndexPath:indexPath];
    }
    

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
   
    [self.tableView reloadData]; 

}

- (void)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
}

-(IBAction) sortOrderChanged {
  
    if (self.sortControl.selectedSegmentIndex <0) return;
    
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
    
    NSArray *sortedArray = [self.searchResults sortedArrayUsingDescriptors:mySortDescriptors];
    self.searchResults = [sortedArray mutableCopy];
    [self.tableView reloadData];
    
}


@end
