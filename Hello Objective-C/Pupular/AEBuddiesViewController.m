//
//  AEBuddiesViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//


//
//  AEBuddiesViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEBuddiesViewController.h"
#import "AEMenuViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AEFriendProfileViewController.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "AEAppDelegate.h"

@interface AEBuddiesViewController ()
@end

@implementation AEBuddiesViewController
@synthesize tableView,searchBar,trackingSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        friendsArray = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)viewDidLoad
{
    [self loadUserInfo];
    [super viewDidLoad];
        [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    _navBar.topItem.rightBarButtonItem = nil;
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://dry-shelf-9195.herokuapp.com/friend_list?dog_id=%@",_dogID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadUserInfo];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _allDogs = appDelegate.allDogs;
    NSString *dogID = _dogID;
    [self buildFriendsArray];

    _dog = [_allDogs objectForKey:[NSString stringWithFormat:@"%@",_dogID]];
    _navBar.topItem.title = [NSString stringWithFormat:@"%@'s Pack",[_dog valueForKey:@"handle"]];

    if([userInfo valueForKey:@"is_active"]){
        if([[userInfo valueForKey:@"is_active"] isEqualToString:@"true"]){
            [trackingSwitch setOn:YES];
        }
        else{
            [trackingSwitch setOn:NO];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
    menuView.locationController = _locationController;
    [self presentViewController:menuView animated:YES completion:nil];
}

-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(IBAction)list:(id)sender{
    AEActiveFriendsViewController *activeFriendsView = [[AEActiveFriendsViewController alloc] init];
    [self presentViewController:activeFriendsView animated:NO completion:nil];
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
    if([newJSON objectForKey:@"friends"])
    {
        friendsArray = [newJSON objectForKey:@"friends"];
        [self buildFriendsArray];
        [self.tableView reloadData];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [friendsArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *user;


    NSString *imageString = nil;
    [cell.imageView setImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    if(searchResults){
        user = [searchResults objectAtIndex:indexPath.row];
    }
    else {
        user = [friendsArray objectAtIndex:indexPath.row];
    }
    
    
    imageString = [user valueForKey:@"photo_list"][1];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    if([imageString isEqualToString:@"none"]){
        [cell.imageView setImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    }
    else{
        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageString]]
                       placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [user valueForKey:@"handle"];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 25;
    [cell.imageView.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
    [cell.imageView.layer setBorderWidth: 1.0];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *userDict = [friendsArray objectAtIndex:indexPath.row];
    AEFriendProfileViewController *friendProfileView = [[AEFriendProfileViewController alloc] init];
    NSString *dogID = [userDict valueForKey:@"id"];
    friendProfileView.locationController = _locationController;
    friendProfileView.dogID = dogID;
    [self presentViewController:friendProfileView animated:NO completion:nil];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *friendship_id = [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"friend_id"];
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://dry-shelf-9195.herokuapp.com/delete_friendship?friendship_id=%@",friendship_id]]];
        NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
        [friendsArray removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)buildFriendsArray{
    friendsArray = [[NSMutableArray alloc] init];
    for(id key in _allDogs){
        NSMutableDictionary *thisDog = _allDogs[key];
        NSArray *thisDogsFriends = [thisDog objectForKey:@"friend_ids"];
        for(int i=0; i < thisDogsFriends.count; i++){
           NSString *thisID = [thisDogsFriends objectAtIndex:i];
            NSString *dogID= _dogID;
            if([dogID intValue] == [thisID intValue]){
                [friendsArray addObject:_allDogs[key]];
            }
            else{
            }
        }
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"handle contains[c] %@", searchText];
    searchResults = [friendsArray filteredArrayUsingPredicate:resultPredicate];
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
