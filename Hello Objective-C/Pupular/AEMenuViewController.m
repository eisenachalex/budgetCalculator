//
//  AEMenuViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEMenuViewController.h"
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
#import "AEAppDelegate.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface AEMenuViewController ()

@end

@implementation AEMenuViewController
@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"More";


    }
    return self;
}

- (void)viewDidLoad
{
    [self loadUserInfo];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadUserInfo];
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/all_dogs?dog_id=%@",[userInfo objectForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)about:(id)sender {
    AEAboutViewController *aboutView = [[AEAboutViewController alloc] init];
    aboutView.locationController = _locationController;
    [self presentViewController:aboutView animated:NO completion:nil];
}

-(IBAction)profile:(id)sender {
    AEProfileViewController *profileView = [[AEProfileViewController alloc] init];
    profileView.dogID = [userInfo valueForKey:@"dog_id"];
    profileView.dogHandle = [userInfo valueForKey:@"dog_handle"];
    [self presentViewController:profileView animated:NO completion:nil];
}

-(IBAction)activeFriends:(id)sender {
    AEActiveFriendsViewController *activeFriendsView = [[AEActiveFriendsViewController alloc] init];
    activeFriendsView.locationController = _locationController;
    [self presentViewController:activeFriendsView animated:NO completion:nil];
}

-(IBAction)signout:(id)sender {
    [_locationController.locationManager stopUpdatingLocation];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/deactivate?email=%@",[userInfo objectForKey:@"email"]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [userInfo setValue:@"empty" forKey:@"email"];
    [userInfo setValue:@"false" forKey:@"is_active"];
    [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    AELogInViewController *loginViewController = [[AELogInViewController alloc] init];
    loginViewController.delegate = [self.tabBarController.viewControllers objectAtIndex:0];
    [self presentViewController:loginViewController animated:NO completion:nil];
}

-(void)loginComplete{
    [self.tabBarController setSelectedIndex:0];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    }
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *user = nil;
    user = [[searchResults objectAtIndex:indexPath.row] valueForKey:@"handle"];
    NSString *imageString = [[searchResults objectAtIndex:indexPath.row] valueForKey:@"photo"];
    if([imageString isEqualToString:@"none"]){
        [cell.imageView setImage:[UIImage imageNamed:@"filler_icon"]];
    }
    else{
        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageString]]
                       placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = user;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 25;
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
            handle = [userDict valueForKey:@"handle"];
            NSString *stringValue = [NSString stringWithFormat:@"%@",[userDict valueForKey:@"is_friend"]];
            if([stringValue isEqualToString:@"1"]){
                _isFriend = YES;
            }
            else{
                _isFriend = NO;
            }
        }
    }
    AEFriendProfileViewController *profileView = [[AEFriendProfileViewController alloc] init];
    profileView.dogID = dogID;
    profileView.view.translatesAutoresizingMaskIntoConstraints = YES;
    profileView.isMine = YES;
    profileView.dogHandle = handle;
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
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}

@end