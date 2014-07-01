//
//  AEHomeViewController.m
//  Sketch
//
//  Created by Alex Eisenach on 4/27/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEHomeViewController.h"
#import "AELoginViewController.h"
#import "AEMapViewController.h"

@interface AEHomeViewController ()
@end

@implementation AEHomeViewController
@synthesize tableView,switcher;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        tableView.contentInset = UIEdgeInsetsMake(0,0,200,0);

        self.title = @"Home";
        [self loadUserInfo];
        [self.switcher setOn:FALSE];
        [self tracking_button:switcher];
    }
    return self;
}
- (void)viewDidLoad {
    [self loadStatus];
    tableView.contentInset = UIEdgeInsetsMake(0,0,200,0);

    NSString *status = [current_status objectAtIndex:0];
    locationController = [[AECLController alloc] init];
    locationController.delegate = self;

    [self loadFriends];
    [self loadUserInfo];
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/friends"]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadUserInfo];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [myRecents count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Display recipe in the table cell
    NSString *user = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        user = [searchResults objectAtIndex:indexPath.row];
    } else {
        user = [myRecents objectAtIndex:indexPath.row];
    }
    //cell.thumbnailImageView.image = [UIImage imageNamed:recipe.image];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = user;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    return cell;
}

- (void)loadFriends {
    NSString *filePath = [self pathForResource:@"recentFriends.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        myRecents = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        myRecents = [NSMutableArray array];
    }
}

- (void)loadStatus{
    NSString *filePath = [self pathForResource:@"status.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        current_status = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        current_status = [[NSMutableArray alloc] init];
        [current_status addObject:@"false"];
    }
}
- (NSString *)pathForResource:(NSString*)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:fileName];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSString *username = cell.textLabel.text;

        if(![myRecents containsObject:username]){
            [myRecents addObject:username];
            [self save:myRecents withFile:@"recentFriends.plist"];
            
        }
        [self.searchDisplayController setActive:NO animated:YES];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([myRecents count] - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];

    }
    else if([self.switcher isOn]){
        if([cell.textLabel.textColor isEqual:[UIColor greenColor]]){
            cell.textLabel.textColor = [UIColor darkGrayColor];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/delete_session?sender=%@&receiver=%@",[userInfo objectAtIndex:0],cell.textLabel.text]]];
            NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

        }
        else{
            cell.textLabel.textColor = [UIColor greenColor];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/create_session?sender=%@&receiver=%@",[userInfo objectAtIndex:0],cell.textLabel.text]]];
            NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

        }
    }
    else if(![self.switcher isOn]){
        cell.textLabel.textColor = [UIColor greenColor];

        [self.switcher setOn:TRUE];

        [self tracking_button:switcher];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/create_session?sender=%@&receiver=%@",[userInfo objectAtIndex:0],cell.textLabel.text]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    }

    
}

-(void)save:(NSMutableArray *)object withFile:(NSString *)file{
    [object writeToFile:[self pathForResource:file] atomically:YES];
}

-(void)determineAllowedFriends {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/allowed_friends?username=%@",[userInfo objectAtIndex:0]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    return @"People who can track me";
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"self contains[c] %@", searchText];
    searchResults = [usersArray filteredArrayUsingPredicate:resultPredicate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tracking_button:(id)sender {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if([sender isOn] == true){

        //[current_status replaceObjectAtIndex:0 withObject:@"true"];
        //[self save:current_status withFile:@"status.plist"];
        [locationController.locationManager startUpdatingLocation];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/is_active?active=yes&username=%@",[userInfo objectAtIndex:0]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        UIImage *signal_on = [[UIImage imageNamed:@"track_star_signal_ON.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        [self.tabBarItem setImage:signal_on];

    }
    else if([sender isOn] == false) {
        //[current_status replaceObjectAtIndex:0 withObject:@"false"];
        //[self save:current_status withFile:@"status.plist"];
        [self.tableView reloadData];
        [locationController.locationManager stopUpdatingLocation];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/is_active?active=no&username=%@",[userInfo objectAtIndex:0]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSURLRequest *second_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/delete_session?sender=%@",[userInfo objectAtIndex:0]]]];
        NSURLConnection *second_conn = [[NSURLConnection alloc] initWithRequest:second_request delegate:self];
        UIImage *signal_off = [[UIImage imageNamed:@"track_star_signal_OFF.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        [self.tabBarItem setImage:signal_off];

    }
}




- (void)locationUpdate:(CLLocation *)location {
    NSLog(@"updating jowns");
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/update?latitude=%f&longitude=%f&username=%@",location.coordinate.latitude, location.coordinate.longitude,[userInfo objectAtIndex:0]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)locationError:(NSError *)error {
}




- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    if([newJSON objectForKey:@"users"])
    {
        usersArray = [newJSON valueForKey:@"users"];

    }
    else if([newJSON objectForKey:@"allowed"]) {
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    //self.statusLabel.text = @"Unable to Connect";
}


- (void)loadUserInfo {
    NSString *filePath = [self pathForUserInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userInfo = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        userInfo = [NSMutableArray arrayWithObjects:@"empty",@"blank", nil];
        
    }
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    NSLog(@"path %@",paths);
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [myRecents removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];

        [self save:myRecents withFile:@"recentFriends.plist"];
        [self loadFriends];
    }
}

@end
