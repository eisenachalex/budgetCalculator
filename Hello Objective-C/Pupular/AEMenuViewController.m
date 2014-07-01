//
//  AEMenuViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEMenuViewController.h"
#import "AEHomeMapViewController.h"
#import "AEProfileViewController.h"
#import "AEMessagesViewController.h"
#import "AEAboutViewController.h"
#import "AEBuddiesViewController.h"
#import "AELogInViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AEAdditionView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface AEMenuViewController ()

@end

@implementation AEMenuViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // Do any additional setup after loading the view from its nib.
    
}

-(void)viewWillAppear:(BOOL)animated{
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/all_dogs"]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    [self loadUserInfo];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)home:(id)sender {
    AEHomeMapViewController *homeView = [[AEHomeMapViewController alloc] init];
    [self presentViewController:homeView animated:NO completion:nil];
}

-(IBAction)messages:(id)sender {
    AEMessagesViewController *messagesView = [[AEMessagesViewController alloc] init];
    [self presentViewController:messagesView animated:NO completion:nil];
}

-(IBAction)about:(id)sender {
    AEAboutViewController *aboutView = [[AEAboutViewController alloc] init];
    [self presentViewController:aboutView animated:NO completion:nil];
}

-(IBAction)buddies:(id)sender {
    AEBuddiesViewController *buddiesView = [[AEBuddiesViewController alloc] init];
    [self presentViewController:buddiesView animated:NO completion:nil];
}

-(IBAction)profile:(id)sender {
    AEProfileViewController *profileView = [[AEProfileViewController alloc] init];
    profileView.dogID = [userInfo valueForKey:@"dog_id"];
    profileView.dogHandle = [userInfo valueForKey:@"dog_handle"];
    profileView.isMine = TRUE;
    [self presentViewController:profileView animated:NO completion:nil];
}

-(IBAction)activeFriends:(id)sender {
    AEActiveFriendsViewController *activeFriendsView = [[AEActiveFriendsViewController alloc] init];
    [self presentViewController:activeFriendsView animated:NO completion:nil];
}


-(IBAction)signout:(id)sender {
    [userInfo setValue:@"empty" forKey:@"email"];
    [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    AELogInViewController *loginViewController = [[AELogInViewController alloc] init];
    [self presentViewController:loginViewController animated:YES completion:nil];
    
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
        [cell.imageView setImage:[UIImage imageNamed:@"git_icon_hover.png"]];
    }
    else{
        NSLog(@"yes");
        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageString]]
                       placeholderImage:[UIImage imageNamed:@"git_icon_hover.png"]];
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
    NSString *dogID = [NSString alloc];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    for (int i = 0; i < usersArray.count; i++){
        NSDictionary *userDict = [usersArray objectAtIndex:i];
        if([[userDict valueForKey:@"handle"] isEqualToString:cell.text]){
            dogID = [userDict valueForKey:@"id"];
        }
    }
    NSLog(@"okay %@",dogID);
    AEProfileViewController *profileView = [[AEProfileViewController alloc] init];
    profileView.dogID = dogID;
    profileView.isFriend = FALSE;
    profileView.dogHandle = cell.text;
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
