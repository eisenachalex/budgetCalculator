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

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUserInfo];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tap)];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"image_url"]]];
    NSLog(@"user jowns %@",[userInfo objectForKey:@"image_url"]);
    NSLog(@"we got that imageurl %@",imageURL);
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage *image = [UIImage imageWithData:imageData];
    
    
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    [face addTarget:self action:@selector(target:) forControlEvents:UIControlEventTouchUpInside];

    face.imageView.clipsToBounds = YES;
    face.imageView.layer.cornerRadius = 18;
    face.bounds = CGRectMake( 0, 0, 35, 35 );
    [face setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *faceBtn = [[UIBarButtonItem alloc] initWithCustomView:face];
    [_targetItem setLeftBarButtonItem:faceBtn];

    // Do any additional setup after loading the view from its nib.
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"OKKKK");
    NSString *dogID = [[NSString alloc] init];
    NSString *handle = [[NSString alloc] init];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    for (int i = 0; i < friendsArray.count; i++){
        NSDictionary *userDict = [friendsArray objectAtIndex:i];
        if([[userDict valueForKey:@"handle"] isEqualToString:cell. text]){
            
            dogID = [userDict valueForKey:@"id"];
            handle = [userDict objectForKey:@"handle"];
            NSLog(@"HANDLE IT SON %@",handle);
            NSString *stringValue = [NSString stringWithFormat:@"%@",[userDict valueForKey:@"is_friend"]];
      
                _isFriend = YES;

            
        }
    }
    NSLog(@"okay %@",dogID);
    AEFriendProfileViewController *profileView = [[AEFriendProfileViewController alloc] init];
    profileView.dogID = dogID;
    profileView.isFriend = _isFriend;
    profileView.dogHandle = [NSString stringWithFormat:@"%@",handle];
    [self presentViewController:profileView animated:NO completion:nil];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *friendship_id = [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"friend_id"];
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/delete_friendship?friendship_id=%@",friendship_id]]];
        NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
        [friendsArray removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillDisappear:(BOOL)animated{
    [self stopTimer];
}

-(void)tap {
    NSLog(@"jowns");
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadUserInfo];
    [self startTimer];
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



- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSLog(@"jowtn");
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"handle contains[c] %@", searchText];
    searchResults = [friendsArray filteredArrayUsingPredicate:resultPredicate];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    for(int i = 0; i < [[cell.textLabel subviews] count]; i++){
        
        UIView *currentView = [[cell.textLabel subviews] objectAtIndex:i];
        [currentView removeFromSuperview];
        
    }
    for(int i = 0; i < [[cell.contentView subviews] count]; i++){
        
        UIView *currentView = [[cell.contentView subviews] objectAtIndex:i];
        [currentView removeFromSuperview];
        
    }
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *friendDict;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"NOW ITS OWN");
        friendDict = [searchResults objectAtIndex:indexPath.row];

    }
    else{
        friendDict = [friendsArray objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = [friendDict objectForKey:@"handle"];
    [cell.textLabel setFont:[UIFont fontWithName:@"Avenir Next" size:15]];
    NSString *photoURL = [friendDict objectForKey:@"photo"];
    NSLog(@"PHOTO URLLLL %@",photoURL);
    NSLog(@"DOG HANDLE %@", cell.text);
    if([photoURL isEqualToString:@"none"]){
        [cell.imageView setImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png.png"]];
    }
    else{
        [cell.imageView setImageWithURL:[NSURL URLWithString:photoURL]
                       placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    }
    
    //messaeg button
    
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [messageButton setImage:[UIImage imageNamed:@"pupular_message_default.png"] forState:UIControlStateNormal];
    messageButton.frame = CGRectMake(210.0, 0, 60.0, 90.0);
    messageButton.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.1 alpha:1];
    [messageButton addTarget:self action:@selector(messageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    messageButton.tag = indexPath.row;
    [cell.contentView addSubview:messageButton];
    
    //target button
    
    UIButton *targetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [targetButton setImage:[UIImage imageNamed:@"pupular_track.png"] forState:UIControlStateNormal];
    targetButton.frame = CGRectMake(270.0, 0, 60.0, 90.0);
    targetButton.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.1 alpha:1];

    [targetButton addTarget:self action:@selector(targetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    targetButton.tag = indexPath.row;
    if([[friendDict valueForKey:@"is_active"] boolValue] == YES){
        [cell.contentView addSubview:targetButton];

    }
    
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 25;
    return cell;
}

- (void)messageButtonTapped:(id)sender
{
    NSDictionary *friendDict = [friendsArray objectAtIndex:[sender tag]];
    NSString *dog_id = [friendDict valueForKey:@"id"];
    AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
    conversationView.locationController = _locationController;
    UILabel *handleLabel = [[UILabel alloc] init];
    handleLabel.text = [friendDict valueForKey:@"handle"];
    NSString *photoURL = [friendDict objectForKey:@"photo"];
    if([photoURL isEqualToString:@"none"]){
        conversationView.senderImage = [UIImage imageNamed:@"git_icon_hover.png"];
    }
    else{
        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
        conversationView.senderImage = image;

    }
    conversationView.dogHandle = handleLabel.text;
    conversationView.dogID = dog_id;
    [self presentViewController:conversationView animated:NO completion:nil];
    
}

- (void)targetButtonTapped:(id)sender
{
    NSDictionary *friendDict = [friendsArray objectAtIndex:[sender tag]];
    NSString *dog_id = [friendDict valueForKey:@"id"];
    NSLog(@"on the active friends view it is %@",dog_id);
//    AETargetMapViewController *targetView = [[AETargetMapViewController alloc] init];
//    targetView.locationController = _locationController;
//    targetView.target_id = dog_id;
//    [self presentViewController:targetView animated:NO completion:nil];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.targetID = dog_id;
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
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    NSLog(@"all friends%@",[newJSON objectForKey:@"friend_list"]);
    if([newJSON objectForKey:@"friend_list"])
    {
        friendsArray = [newJSON objectForKey:@"friend_list"];
        friendsArray = [friendsArray mutableCopy];
        [self.tableView reloadData];
    }
    
}


-(IBAction)trackingSwitch:(id)sender{
    if([sender isOn])
    {
        NSLog(@"trakcing controller %@",_locationController);
        NSLog(@"True");
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/walk_alert?dog_id=%@",[userInfo objectForKey:@"dog_id"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [_locationController.locationManager startUpdatingLocation];
        [userInfo setValue:@"true" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    else{
        NSLog(@"false");
        [userInfo setValue:@"false" forKey:@"is_active"];
        
        [_locationController.locationManager stopUpdatingLocation];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/deactivate?email=%@",[userInfo objectForKey:@"email"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [userInfo setValue:@"false" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    
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
//    if(_hasNotification){
//        UIButton *notificationMenu = [UIButton buttonWithType:UIButtonTypeCustom];
//        notificationMenu.bounds = CGRectMake( 0, 0, 20, 20 );
//        
//        [notificationMenu addTarget:self action:@selector(messages:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [notificationMenu setImage:[UIImage imageNamed:@"list24.png"] forState:UIControlStateNormal];
//        UIBarButtonItem *notificationButton= [[UIBarButtonItem alloc] initWithCustomView:notificationMenu];
//        [_targetItem setRightBarButtonItem:notificationButton];
//    }
//    else{
//        UIButton *notificationMenu = [UIButton buttonWithType:UIButtonTypeCustom];
//        notificationMenu.bounds = CGRectMake( 0, 0, 20, 20 );
//        
//        [notificationMenu addTarget:self action:@selector(menu:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [notificationMenu setImage:[UIImage imageNamed:@"list23.png"] forState:UIControlStateNormal];
//        UIBarButtonItem *notificationButton= [[UIBarButtonItem alloc] initWithCustomView:notificationMenu];
//        [_targetItem setRightBarButtonItem:notificationButton];
//        
//        
//    }
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/friend_list?dog_id=%@",[userInfo valueForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
//
//DO SOMETHING TO REFRESH VIEW HERE
    
}


@end
