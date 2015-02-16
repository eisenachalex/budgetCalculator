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
    

    // Do any additional setup after loading the view from its nib.
    
}



-(void)viewDidAppear:(BOOL)animated{
    [self loadUserInfo];
    self.searchBar.delegate = self;
    self.message.delegate = self;
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/all_dogs?dog_id=%@",[userInfo objectForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/new_message?sender_id=%@&receiver_id=%@&message_type=message&body=%@",[userInfo valueForKey:@"dog_id"],receiver_id,[self.message.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
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
        NSLog(@"jowns");
        return [searchResults count];
        
    }
    else {
        return 0;
    }
    NSLog(@"NUMBERS %@",searchResults);
    
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
    NSLog(@"THE USER BOI %@",user);
    //cell.thumbnailImageView.image = [UIImage imageNamed:recipe.image];
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
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 25;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = user;
    cell.textLabel.textColor = [UIColor darkGrayColor];
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
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Succeeded! Received %d bytes of data", [_responseData length]);
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
