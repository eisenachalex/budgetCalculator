//
//  AEActiveFriendsViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEActiveFriendsViewController.h"
#import "AEHomeMapViewController.h"
#import "AEConvoViewController.h"
#import "AEMenuViewController.h"
#import "UIImageView+WebCache.h"
#import "AEAppDelegate.h"
#import "AEFriendProfileViewController.h"
#import "AEMessagesViewController.h"
@interface AEActiveFriendsViewController ()

@end

@implementation AEActiveFriendsViewController
@synthesize activeFriendsArray, tableView,trackingSwitch, searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        friendsArray = [[NSMutableArray alloc] init];
        self.title = @"Pack";
        tableView.frame = self.view.frame;
        _fillerView = nil;
    }
    return self;
}

-(void)setThumbImage{
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"image_url"]]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage *image = [UIImage imageWithData:imageData];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    [face addTarget:self action:@selector(target:) forControlEvents:UIControlEventTouchUpInside];
    face.imageView.clipsToBounds = YES;
    face.imageView.image = nil;
    face.imageView.layer.cornerRadius = 18;
    face.bounds = CGRectMake( 0, 0, 35, 35 );
    [face setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *faceBtn = [[UIBarButtonItem alloc] initWithCustomView:face];
    [_targetItem setLeftBarButtonItem:faceBtn];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self loadUserInfo];
    _imageURL = [userInfo valueForKey:@"image_url"];
    [self setThumbImage];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dogID = [[NSString alloc] init];
    NSString *handle = [[NSString alloc] init];
    NSMutableArray *dataArray;
    NSMutableDictionary *userDict;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        dataArray = searchResults;
    }
    else{
        dataArray = friendsArray;
        
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        userDict = [dataArray objectAtIndex:indexPath.row];
    }
    else{
        NSString *profileDogID = [dataArray objectAtIndex:indexPath.row];
        userDict = [_allDogs objectForKey:[NSString stringWithFormat:@"%@",profileDogID]];
    }
    if([[userDict valueForKey:@"handle"] isEqualToString:cell.text]){
            dogID = [userDict valueForKey:@"id"];
            handle = [userDict objectForKey:@"handle"];
            NSString *stringValue = [NSString stringWithFormat:@"%@",[userDict valueForKey:@"is_friend"]];
                _isFriend = YES;
    }
    AEFriendProfileViewController *profileView = [[AEFriendProfileViewController alloc] init];
    profileView.dogID = [userDict valueForKey:@"id"];
    profileView.isFriend = _isFriend;
    profileView.dogHandle = [NSString stringWithFormat:@"%@",handle];
    [self presentViewController:profileView animated:NO completion:nil];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *friendship_id = [friendsArray objectAtIndex:indexPath.row];
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/delete_friendship?friendship_id=%@&dog_id=%@",friendship_id,[userInfo valueForKey:@"dog_id"]]]];
        NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
        [friendsArray removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)viewWillDisappear:(BOOL)animated{
    [self stopTimer];
}

-(void)tap {
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadUserInfo];
    [self startTimer];
    [_spinner startAnimating];
    [self.tableView reloadData];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _allDogs = appDelegate.allDogs;
    NSString *currentImage = [userInfo valueForKey:@"image_url"];
    if(![currentImage isEqualToString:_imageURL]){
        [self setThumbImage];
        _imageURL = [userInfo valueForKey:@"image_url"];
    }
    if([userInfo valueForKey:@"is_active"]){
        if([[userInfo valueForKey:@"is_active"] isEqualToString:@"true"]){
            [trackingSwitch setOn:YES];
        }
        else {
            [trackingSwitch setOn:NO];
        }
    }
}



-(IBAction)messages:(id)sender{
    AEMessagesViewController *messagesView = [[AEMessagesViewController alloc] init];
    messagesView.locationController = _locationController;
    
    [self presentViewController:messagesView animated:NO completion:nil];
}

-(IBAction)homeMapView:(id)sender{

    [self dismissViewControllerAnimated:NO completion:nil];


}


-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
    menuView.locationController = _locationController;

    [self presentViewController:menuView animated:YES completion:nil];
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
    return [friendsArray count];
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


-(void)buildUsersArray{
    usersArray = [[NSMutableArray alloc] init];
    for(id key in _allDogs){
        for(int i = 0; i < friendsArray.count; i++){
            NSString *friendID = [friendsArray objectAtIndex:i];
            NSString *newFriend = [NSString stringWithFormat:@"%@",friendID];
            NSString *thisKey = [NSString stringWithFormat:@"%@",key];
            if([thisKey isEqualToString:newFriend]){
                [usersArray addObject:_allDogs[key]];
            }
        }
    }
}




- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"handle contains[c] %@", searchText];
    searchResults = [usersArray filteredArrayUsingPredicate:resultPredicate];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    for(int i = 0; i < [[cell.textLabel subviews] count]; i++){
        UIView *currentView = [[cell.textLabel subviews] objectAtIndex:i];
        [currentView removeFromSuperview];
    }
//    for(int i = 0; i < [[cell.contentView subviews] count]; i++){
//        UIView *currentView = [[cell.contentView subviews] objectAtIndex:i];
//        [currentView removeFromSuperview];
//    }
    [[cell.contentView subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *thisDog;
    NSDictionary *friendDict;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        thisDog = [[searchResults objectAtIndex:indexPath.row] valueForKey:@"id"];
    }
    else{
        thisDog = [friendsArray objectAtIndex:indexPath.row];
    }
    friendDict = [_allDogs objectForKey:[NSString stringWithFormat:@"%@",thisDog]];
    cell.textLabel.text = [friendDict objectForKey:@"handle"];
    [cell.textLabel setFont:[UIFont fontWithName:@"Avenir Next" size:15]];
    NSString *photoURL = [friendDict objectForKey:@"photo_list"][1];
    if([photoURL isEqualToString:@"none"]){
        [cell.imageView setImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    }
    else{
        [cell.imageView setImageWithURL:[NSURL URLWithString:photoURL]
                       placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    }
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [messageButton setImage:[UIImage imageNamed:@"pupular_message_default.png"] forState:UIControlStateNormal];
    messageButton.frame = CGRectMake(210.0, 0, 60.0, 90.0)
;
    messageButton.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.1 alpha:1];
    [messageButton addTarget:self action:@selector(messageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    messageButton.tag = indexPath.row;
    [cell.contentView addSubview:messageButton];
    UIButton *targetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [targetButton setImage:[UIImage imageNamed:@"pupular_track.png"] forState:UIControlStateNormal];
    targetButton.frame = CGRectMake(270.0, 0, 60.0, 90.0);
    targetButton.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.1 alpha:1];

    [targetButton addTarget:self action:@selector(targetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    targetButton.tag = indexPath.row;
    NSString *friendID = [friendDict objectForKey:@"id"];
    for(int i = 0; i < activeFriendsArray.count; i++){
        NSString *thisID = [activeFriendsArray objectAtIndex:i];
        if([thisID intValue] == [friendID intValue]){
            [cell.contentView addSubview:targetButton];
            break;
        }
    }
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 25;
    return cell;
}

- (void)messageButtonTapped:(id)sender
{
    NSString *friendID;
    if (self.tableView == self.searchDisplayController.searchResultsTableView) {
            friendID = [searchResults objectAtIndex:[sender tag]];
    }
    else{
        friendID = [friendsArray objectAtIndex:[sender tag]];
    }
    NSMutableDictionary *friendDict = [_allDogs objectForKey:[NSString stringWithFormat:@"%@",friendID]];
    AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
    conversationView.locationController = _locationController;
    UILabel *handleLabel = [[UILabel alloc] init];
    handleLabel.text = [friendDict valueForKey:@"handle"];
    NSString *photoURL = [friendDict objectForKey:@"photo_list"][1];
    if([photoURL isEqualToString:@"none"]){
        conversationView.senderImage = [UIImage imageNamed:@"git_icon_hover.png"];
    }
    else{
        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
        conversationView.senderImage = image;

    }
    conversationView.dogHandle = handleLabel.text;
    conversationView.dogID = [friendDict valueForKey:@"id"];
    [self presentViewController:conversationView animated:NO completion:nil];
}

- (void)targetButtonTapped:(id)sender
{
    NSString *friendID = [friendsArray objectAtIndex:[sender tag]];
    NSMutableDictionary  *friendDict = [_allDogs objectForKey:[NSString stringWithFormat:@"%@",friendID]];
    NSString *dogID = [friendDict valueForKey:@"id"];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.targetID = dogID;
    appDelegate.mapHasTarget = YES;
    [self.tabBarController setSelectedIndex:0];
}

- (void)target:(id)sender
{
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mapHasTarget = NO;
     [self.tabBarController setSelectedIndex:0];
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
    [_spinner stopAnimating];
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    if([newJSON objectForKey:@"friends"])
    {
        friendsArray = [newJSON objectForKey:@"friends"];
        if(friendsArray.count == 0){
            self.tableView.hidden = YES;
            if(_fillerView == nil){
                UIView *messageFiller = [[[[NSBundle mainBundle] loadNibNamed:@"AEPackViewFiller" owner:self options:nil] objectAtIndex:0] initWithFrame:CGRectMake(200, 400, 2, 3)];
                UIView *frameSauce = [[UIView alloc] initWithFrame:CGRectMake(0,110,200,300)];
                [frameSauce addSubview:messageFiller];
                _fillerView = frameSauce;
                [self.view addSubview:frameSauce];
            }
        }
        else{
            self.tableView.hidden = NO;
            [_fillerView removeFromSuperview];
            _fillerView = nil;
        }

        activeFriendsArray = [newJSON objectForKey:@"active"];
        friendsArray = [friendsArray mutableCopy];
        [self buildUsersArray];
        [self.tableView reloadData];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Block";
}

-(IBAction)trackingSwitch:(id)sender{
    [self.delegate switched];
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

- (void) startTimer
{
    self.myTime = [NSTimer scheduledTimerWithTimeInterval:5
                                                   target:self
                                                 selector:@selector(timerFired:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void) stopTimer
{
    [self.myTime invalidate];
}

- (void) timerFired:(NSTimer*)theTimer
{
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/friend_list?dog_id=%@",[userInfo valueForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];

}

@end
