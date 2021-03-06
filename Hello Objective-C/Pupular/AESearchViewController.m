//
//  AEMenuViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AESearchViewController.h"
#import "AEHomeMapViewController.h"
#import "AEFriendProfileViewController.h"
#import "AEMessagesViewController.h"
#import "AEAboutViewController.h"
#import "AEConvoViewController.h"
#import "AEBuddiesViewController.h"
#import "AELogInViewController.h"
#import "AEProfileViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AEAdditionView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface AESearchViewController ()

@end

@implementation AESearchViewController
@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Search";
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [self loadUserInfo];
    [super viewDidLoad];
    NSLog(@"LOCATION CONTROLLER %@",_locationController);
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];

    // Do any additional setup after loading the view from its nib.
    
}



-(void)viewWillAppear:(BOOL)animated{
    [self loadUserInfo];
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/all_dogs?dog_id=%@",[userInfo objectForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    if([userInfo valueForKey:@"is_active"]){
        if([[userInfo valueForKey:@"is_active"] isEqualToString:@"true"]){
            [_trackingSwitch setOn:YES];
        }
        else{
            [_trackingSwitch setOn:NO];
        }
    }
}

-(IBAction)trackingSwitch:(id)sender{
    if([sender isOn]){
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/walk_alert?dog_id=%@",[userInfo objectForKey:@"dog_id"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [_locationController.locationManager startUpdatingLocation];
        [userInfo setValue:@"true" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    else{
        
        [_locationController.locationManager stopUpdatingLocation];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/deactivate?email=%@",[userInfo objectForKey:@"email"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [userInfo setValue:@"false" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)home:(id)sender {
    AEHomeMapViewController *homeMapView = [[AEHomeMapViewController alloc] init];
    homeMapView.locationController = _locationController;
    [self presentViewController:homeMapView animated:NO completion:nil];
}

-(IBAction)messages:(id)sender {
    AEMessagesViewController *messagesView = [[AEMessagesViewController alloc] init];
    messagesView.locationController = _locationController;
    
    [self presentViewController:messagesView animated:NO completion:nil];
}

-(IBAction)about:(id)sender {
    AEAboutViewController *aboutView = [[AEAboutViewController alloc] init];
    aboutView.locationController = _locationController;
    [self presentViewController:aboutView animated:NO completion:nil];
}

-(IBAction)buddies:(id)sender {
    AEBuddiesViewController *buddiesView = [[AEBuddiesViewController alloc] init];
    buddiesView.locationController = _locationController;
    [self presentViewController:buddiesView animated:NO completion:nil];
}

-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)profile:(id)sender {
    AEProfileViewController *profileView = [[AEProfileViewController alloc] init];
    profileView.dogID = [userInfo valueForKey:@"dog_id"];
    profileView.dogHandle = [userInfo valueForKey:@"dog_handle"];
    profileView.locationController = _locationController;
    profileView.isMine = YES;
    [self presentViewController:profileView animated:NO completion:nil];
}

-(IBAction)activeFriends:(id)sender {
    AEActiveFriendsViewController *activeFriendsView = [[AEActiveFriendsViewController alloc] init];
    activeFriendsView.locationController = _locationController;
    [self presentViewController:activeFriendsView animated:NO completion:nil];
}


-(IBAction)signout:(id)sender {
    NSLog(@"location CONTROLLER %@",_locationController);
    [_locationController.locationManager stopUpdatingLocation];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/deactivate?email=%@",[userInfo objectForKey:@"email"]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [userInfo setValue:@"empty" forKey:@"email"];
    [userInfo setValue:@"false" forKey:@"is_active"];
    [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    AELogInViewController *loginViewController = [[AELogInViewController alloc] init];
    [self presentViewController:loginViewController animated:NO completion:nil];
    
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"jowns");
        return [searchResults count];
        
    }
    else {
        return 0;
    }
    NSLog(@"NUMBERS %@",searchResults);
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    // Display recipe in the table cell
    NSString *user = nil;
    NSLog(@"DEM SEARCH RESULTS %@",searchResults);
    user = [[searchResults objectAtIndex:indexPath.row] valueForKey:@"handle"];
    NSString *imageString = [[searchResults objectAtIndex:indexPath.row] valueForKey:@"photo"];
    NSLog(@"image jownt %@",imageString);
    if([imageString isEqualToString:@"none"]){
        [cell.imageView setImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    }
    else{
        NSLog(@"yes");
        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageString]]
                       placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = user;
    [cell.textLabel setFont:[UIFont fontWithName:@"Avenir Next" size:15]];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 25;
    [cell.imageView.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
    [cell.imageView.layer setBorderWidth: 1.0];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dogID = [[NSString alloc] init];
    NSString *handle = [[NSString alloc] init];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    for (int i = 0; i < usersArray.count; i++){
        NSDictionary *userDict = [usersArray objectAtIndex:i];
        if([[userDict valueForKey:@"handle"] isEqualToString:cell.text]){
            
            dogID = [userDict valueForKey:@"id"];
            handle = [userDict objectForKey:@"handle"];
            NSLog(@"HANDLE IT SON %@",handle);
            NSString *stringValue = [NSString stringWithFormat:@"%@",[userDict valueForKey:@"is_friend"]];
            if([stringValue isEqualToString:@"1"]){
                NSLog(@"A FRIEND");
                _isFriend = YES;
            }
            else{
                _isFriend = NO;
            }
        }
    }
    NSLog(@"okay %@",dogID);
    AEFriendProfileViewController *profileView = [[AEFriendProfileViewController alloc] init];
    profileView.dogID = dogID;
    profileView.isFriend = _isFriend;
    profileView.dogHandle = [NSString stringWithFormat:@"%@",handle];
    [self presentViewController:profileView animated:NO completion:nil];
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
    [spinner stopAnimating];
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    NSLog(@"JSON %@",newJSON);
    if([newJSON objectForKey:@"all_dogs"])
    {
        usersArray = [newJSON valueForKey:@"all_dogs"];
    }
    
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"handle contains[c] %@", searchText];
    searchResults = [usersArray filteredArrayUsingPredicate:resultPredicate];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    //self.statusLabel.text = @"Unable to Connect";
}



- (void)loadUserInfo {
    NSString *filePath = [self pathForUserInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        
    } else {
        userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setValue:@"empty" forKey:@"email"];
    }
    
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    NSLog(@"path %@",paths);
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}




@end