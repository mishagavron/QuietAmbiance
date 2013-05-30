//
//  ResultDetailsViewController.m
//  QuietAmbiance
//
//  Created by Misha Gavronsky on 4/21/13.
//  Copyright (c) 2013 Misha Gavronsky. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ResultDetailsViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Review.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

#import "CorePlot-CocoaTouch.h"

#include "AFImageRequestOperation.h"
#include "ReviewCell.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f


@interface ResultDetailsViewController ()

@end

@implementation ResultDetailsViewController

@synthesize place,placeDetail,viewTotalHeight,reference;

@synthesize hostView = hostView_;

NSString * CPDTickerSymbolAAPL2       = @"AAPL";
NSString * CPDTickerSymbolGOOG2       = @"GOOG";
NSString * CPDTickerSymbolMSFT2       = @"MSFT";

static NSArray *dates = nil;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	return [dates count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	NSInteger valueCount = [dates count];
	switch (fieldEnum) {
		case CPTScatterPlotFieldX:
			if (index < valueCount) {
				return [NSNumber numberWithUnsignedInteger:index];
			}
			break;
			
		case CPTScatterPlotFieldY:
			if ([plot.identifier isEqual:CPDTickerSymbolAAPL2] == YES) {
				return [soundperday objectAtIndex:index];
			}
			break;
	}
	return [NSDecimalNumber zero];
}

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initPlot];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost {
    CGRect parentRect = self.view.bounds;
	parentRect = CGRectMake(parentRect.origin.x,
							(parentRect.origin.y + 145),
							parentRect.size.width,
							(parentRect.size.height - 350));
	// 2 - Create host view
	self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = YES;
    [self.view addSubview:self.hostView];
}

-(void)configureGraph {
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    //graph.plotAreaFrame.borderLineStyle = nil;
	self.hostView.hostedGraph = graph;
	
    // 2 - Set graph title
	//NSString *title = @"Portfolio Prices: April 2012";
	//graph.title = title;
	
    // 3 - Create and set text style
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, 0.0f);
    
	// 4 - Set padding for plot area
	[graph.plotAreaFrame setPaddingLeft:10.0f];
	[graph.plotAreaFrame setPaddingBottom:10.0f];
    
	// 5 - Enable user interactions for plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
	// 1 - Get graph and plot space
	CPTGraph *graph = self.hostView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
	// 2 - Create the three plots
	CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
	aaplPlot.dataSource = self;
	aaplPlot.identifier = CPDTickerSymbolAAPL2;
	CPTColor *aaplColor = [CPTColor redColor];
	[graph addPlot:aaplPlot toPlotSpace:plotSpace];
	CPTScatterPlot *googPlot = [[CPTScatterPlot alloc] init];

	// 3 - Set up plot space
	[plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, nil]];
	CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
	[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
	plotSpace.xRange = xRange;
	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
	[yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
	plotSpace.yRange = yRange;
    
	// 4 - Create styles and symbols
	CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
	aaplLineStyle.lineWidth = 2.5;
	aaplLineStyle.lineColor = aaplColor;
	aaplPlot.dataLineStyle = aaplLineStyle;
	CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
	aaplSymbolLineStyle.lineColor = aaplColor;
	CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
	aaplSymbol.lineStyle = aaplSymbolLineStyle;
	aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
	aaplPlot.plotSymbol = aaplSymbol;
	
}

-(void)configureAxes {
    
	// 1 - Create styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor blackColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 12.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 2.0f;
	axisLineStyle.lineColor = [CPTColor blackColor];
	CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
	axisTextStyle.color = [CPTColor blackColor];
	axisTextStyle.fontName = @"Helvetica-Bold";
	axisTextStyle.fontSize = 8.0f;
	CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor blackColor];
	tickLineStyle.lineWidth = 2.0f;
	CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor blackColor];
	tickLineStyle.lineWidth = 1.0f;
	// 2 - Get axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
	// 3 - Configure x-axis
	CPTAxis *x = axisSet.xAxis;
	//x.title = @"Day of Month";
	x.titleTextStyle = axisTitleStyle;
	x.titleOffset = 15.0f;
	x.axisLineStyle = axisLineStyle;
	x.labelingPolicy = CPTAxisLabelingPolicyNone;
	x.labelTextStyle = axisTextStyle;
	x.majorTickLineStyle = axisLineStyle;
	x.majorTickLength = 4.0f;
	x.tickDirection = CPTSignNegative;
    x.minorTickLineStyle = nil;
	CGFloat dateCount = [dates count];
	NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
	NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
	NSInteger i = 0;
	for (NSString *date in dates) {
		CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
		CGFloat location = i++;
		label.tickLocation = CPTDecimalFromCGFloat(location);
		label.offset = x.majorTickLength;
		if (label) {
			[xLabels addObject:label];
			[xLocations addObject:[NSNumber numberWithFloat:location]];
		}
	}
	x.axisLabels = xLabels;
	x.majorTickLocations = xLocations;
	// 4 - Configure y-axis
	CPTAxis *y = axisSet.yAxis;
	//y.title = @"Price";
	y.titleTextStyle = axisTitleStyle;
	y.titleOffset = -40.0f;
	y.axisLineStyle = axisLineStyle;
	y.majorGridLineStyle = gridLineStyle;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
	y.labelTextStyle = axisTextStyle;
	y.labelOffset = 16.0f;
	y.majorTickLineStyle = axisLineStyle;
	y.majorTickLength = 4.0f;
	y.minorTickLength = 2.0f;
	y.tickDirection = CPTSignPositive;
    y.minorTickLineStyle = nil;
	NSInteger majorIncrement = 10;
	NSInteger minorIncrement = 5;
	CGFloat yMax = 700.0f;  // should determine dynamically based on max price
	NSMutableSet *yLabels = [NSMutableSet set];
	NSMutableSet *yMajorLocations = [NSMutableSet set];
	NSMutableSet *yMinorLocations = [NSMutableSet set];
	for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
		NSUInteger mod = j % majorIncrement;
		if (mod == 0) {
			CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
			NSDecimal location = CPTDecimalFromInteger(j);
			label.tickLocation = location;
			label.offset = -y.majorTickLength - y.labelOffset;
			if (label) {
				[yLabels addObject:label];
			}
			[yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
		} else {
			[yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
		}
	}
	y.axisLabels = yLabels;
	y.majorTickLocations = yMajorLocations;
	y.minorTickLocations = yMinorLocations;
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

    if ([self.reference isEqualToString:self.place.reference]) return; //no need to relad form API
    
    self.viewTotalHeight = 0.0f;
    [self.tableView registerNib:[UINib nibWithNibName:@"ReviewCell" bundle:nil] forCellReuseIdentifier:@"ReviewCell"];
    
    //load Nearby places content
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;

    if (!dates)
    {
        dates = [NSArray arrayWithObjects:
                 @"Mon",
                 @"Tue",
                 @"Wed",
                 @"Thu",
                 @"Fri",
                 @"Sat",
                 @"Sun",
                 nil];
    }
    
    soundperday = [[NSMutableArray alloc] init];
    
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
        NSString *placeid = [resDict objectForKey:@"id"];
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
        
        //adjust table view based on a number of reviews
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y,self.tableView.frame.size.width, 1500.0f);
        
        NSString *placeString  = [NSString stringWithFormat:@"http://upbeat.azurewebsites.net/api/beats/getbeatbygoogleid/%@",placeid];
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
            
            [soundperday addObject:[res objectForKey:@"Monday"]];
            [soundperday addObject:[res objectForKey:@"Tuesday"]];
            [soundperday addObject:[res objectForKey:@"Wednesday"]];
            [soundperday addObject:[res objectForKey:@"Thursday"]];
            [soundperday addObject:[res objectForKey:@"Friday"]];
            [soundperday addObject:[res objectForKey:@"Saturday"]];
            [soundperday addObject:[res objectForKey:@"Sunday"]];
            
            NSLog(@"soundperday: %@", soundperday);
            
            if (soundperday == nil || soundperday.count == 0)
            {
                [soundperday addObject:sampleavg];
                [soundperday addObject:sampleavg];
                [soundperday addObject:sampleavg];
                [soundperday addObject:sampleavg];
                [soundperday addObject:sampleavg];
                [soundperday addObject:sampleavg];
                [soundperday addObject:sampleavg];
            }
       
            //NSString *beatid = [res valueForKeyPath:@"Beat.BeatId"];
            
            //NSLog(@"beatid: %@", beatid);
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
            
            [soundperday addObject:@"0"];
            [soundperday addObject:@"0"];
            [soundperday addObject:@"0"];
            [soundperday addObject:@"0"];
            [soundperday addObject:@"0"];
            [soundperday addObject:@"0"];
            [soundperday addObject:@"0"];
        }];
        
        
        [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:nil];
        [operation start];
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
        self.lReviewsNum.text = [NSString stringWithFormat:@"No Reviews"];
    }
    self.iPhoto.image = self.place.iPhoto;
    self.iRating.image = self.place.iRating;
    self.reference = self.place.reference;

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat height = [Utils getReviewHeaderMarginHeight] + 20.0f;
    if ([self.placeDetail.reviews count] > 0) {
        
        Review *review = [self.placeDetail.reviews objectAtIndex:(long)indexPath.row];
        
        NSString *text = review.text;
        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
        height = MAX(size.height, [Utils getReviewHeaderMarginHeight] + 20.0f);
    
        height = height + (CELL_CONTENT_MARGIN * 2);
        
        height = height + [Utils getReviewHeaderMarginHeight];
        
        self.viewTotalHeight += height;
        
        
        if (indexPath.row == ([self.placeDetail.reviews count] - 1)) {
            
            self.viewTotalHeight += [Utils getReviewTableVerticalOffset];
            //NSLog(@"indexPath.row = %u", indexPath.row);
            //NSLog(@"reviews count - 1 = %u", [self.placeDetail.reviews count] - 1);
            //NSLog(@"total height = %f",self.viewTotalHeight);
            
            self.scrollView.contentSize=CGSizeMake(320,self.viewTotalHeight);

        }

    }
    
    
     return height;
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
      
        [cell.reviewText setLineBreakMode:NSLineBreakByWordWrapping];
        [cell.reviewText setMinimumFontSize:FONT_SIZE];
        [cell.reviewText setNumberOfLines:0];
        [cell.reviewText setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [cell.reviewText setTag:1];
        
        cell.reviewText.layer.borderColor = [UIColor grayColor].CGColor;
        cell.reviewText.layer.borderWidth = 1.0;
        
        
        NSString *text = [Utils convertEscapeTexttoPlainText:review.text];
        
        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        

        [cell.reviewText setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN + [Utils getReviewHeaderMarginHeight], CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
        
        [cell.reviewText setText:text];
        
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
