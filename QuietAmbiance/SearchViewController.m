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
    NSLog((@"Keyboard entry %d", searchText));
	
	// We're still 'in edit mode', if the user left a keyword in the searchBar
	//inSearchMode = (searchText != nil && [searchText length] > 0);
	//[searchBar setShowsCancelButton:inSearchMode animated:true];
	
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
