//
//  AENewMessageViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/5/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//
#import "AENewMessageViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AEMenuViewController.h"
#import "AEConvoViewController.h"
#import "AEAppDelegate.h"
#import "UIImageView+WebCache.h"

@interface AENewMessageViewController ()

@end

@implementation AENewMessageViewController
@synthesize searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        AEActiveFriendsViewController *activeFriendsView = [[AEActiveFriendsViewController alloc] init];

        activeFriendsView.locationController;
        
        AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
        menuView.locationController;

        
  
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUserInfo];
    [self.message becomeFirstResponder];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];

    

    // Do any additional setup after loading the view from its nib.
    
}



-(void)viewDidAppear:(BOOL)animated{
    [self loadUserInfo];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _allDogs = appDelegate.allDogs;
    [self buildUsersArray];
    self.searchBar.delegate = self;
    self.message.delegate = self;
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://dry-shelf-9195.herokuapp.com/all_dogs?dog_id=%@",[userInfo objectForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
}


-(void)buildUsersArray{
    usersArray = [[NSMutableArray alloc] init];
    for(id key in _allDogs){
        [usersArray addObject:_allDogs[key]];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.message becomeFirstResponder];
}
-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
    [self presentViewController:menuView animated:NO completion:nil];
}
-(IBAction)sendMessage:(id)sender{
    //FIX RECEIVER ID FOR NEW MESSAGE
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://dry-shelf-9195.herokuapp.com/new_message?sender_id=%@&receiver_id=%@&message_type=message&body=%@",[userInfo valueForKey:@"dog_id"],receiver_id,[self.message.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
    conversationView.backToMenu = YES;
    conversationView.locationController = _locationController;
    conversationView.senderImage = _receiverImage;
    conversationView.dogHandle = _receiverHandle;
    conversationView.dogID = _dogID;
    [self presentViewController:conversationView animated:NO completion:nil];

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
        
    }
    else {
        return 0;
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
    NSString *dogID = [NSString alloc];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    for(int i = 0; i < usersArray.count; i++){
        NSString *userDict = [usersArray objectAtIndex:i];
        if([[userDict valueForKey:@"handle"] isEqualToString:cell.text]){
           receiver_id = [userDict valueForKey:@"id"];
        }
    }
    [self.searchDisplayController setActive:NO animated:NO];
    self.searchBar.text = cell.text;
    _receiverImage = cell.imageView.image;
    _receiverHandle = cell.text;
    _dogID = receiver_id;
    [self.message becomeFirstResponder];

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
