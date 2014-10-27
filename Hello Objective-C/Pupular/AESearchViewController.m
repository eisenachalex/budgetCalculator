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
#import "AEAppDelegate.h"
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
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
}

-(void)viewWillAppear:(BOOL)animated{
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _allDogs = appDelegate.allDogs;
    [self loadUserInfo];
    [self buildUsersArray];
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
    [self.delegate switched];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)buildUsersArray{
    usersArray = [[NSMutableArray alloc] init];
    for(id key in _allDogs){
        [usersArray addObject:_allDogs[key]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
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
    NSString *imageString = [[searchResults objectAtIndex:indexPath.row] valueForKey:@"photo_list"][1];
    if([imageString isEqualToString:@"none"]){
        [cell.imageView setImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    }
    else{
        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageString]]
                       placeholderImage:[UIImage imageNamed:@"pupular_dog_thumb_avatar.png"]];
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    AEFriendProfileViewController *profileView = [[AEFriendProfileViewController alloc] init];
    NSDictionary *userDict = [searchResults objectAtIndex:indexPath.row];
    profileView.dogID = [userDict valueForKey:@"id"];
    profileView.convoImage = cell.imageView.image;
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
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}

@end