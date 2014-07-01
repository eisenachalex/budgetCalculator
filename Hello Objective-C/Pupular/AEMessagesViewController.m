//
//  AEMessagesViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEMessagesViewController.h"
#import "AEMenuViewController.h"
#import "AENewMessageViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AENotificationViewController.h"
#import "AEConvoViewController.h"
#import "UIImageView+WebCache.h"

@interface AEMessagesViewController ()

@end

@implementation AEMessagesViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        messagesArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUserInfo];

    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/messages?dog_id=%@",[userInfo valueForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/messages?dog_id=%@",[userInfo valueForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    [self.tableView reloadData];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
    [self presentViewController:menuView animated:NO completion:nil];
}

-(IBAction)newMessage:(id)sender{
    AENewMessageViewController *newMessage = [[AENewMessageViewController alloc] init];
    [self presentViewController:newMessage animated:YES completion:nil];
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
    NSLog(@"NEW JSONNNN %@",newJSON);
    if([newJSON objectForKey:@"messages"])
    {
        messagesArray = [[NSMutableArray alloc] init];
        for(int i = 0; i < [[newJSON objectForKey:@"messages"] count]; i++)
        {
        NSDictionary *messageObject = [newJSON objectForKey:@"messages"][i];
        [messagesArray addObject:messageObject];
        }
    }
    NSLog(@"MESASGAGDSAGSD %@",messagesArray);
    [self.tableView reloadData];

}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messagesArray count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"ITS LOADING");
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSLog(@"all the views %@",[cell.textLabel subviews]);
    for(int i = 0; i < [[cell.textLabel subviews] count]; i++){

        UIView *currentView = [[cell.textLabel subviews] objectAtIndex:i];
        [currentView removeFromSuperview];

    }
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Display recipe in the table cell
    NSString *user = nil;
    NSArray *messageArray = [messagesArray objectAtIndex:indexPath.row];
    NSDictionary *messageDict = [messageArray objectAtIndex:0];
    //cell.thumbnailImageView.image = [UIImage imageNamed:recipe.image];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *sender_tag = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,10)];
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(220,10,100,10)];
    [date setFont:[UIFont fontWithName:@"Arial" size:10]];
    [sender_tag setFont:[UIFont fontWithName:@"Arial" size:10]];
    [cell.textLabel setFont:[UIFont fontWithName:@"Arial" size:13]];
    date.text = [messageDict valueForKey:@"created_at"];
    sender_tag.text = [messageArray objectAtIndex:1];
    NSString *imageURL = [messageArray objectAtIndex:2];
    [cell.textLabel addSubview:sender_tag];
    [cell.textLabel addSubview:date];

    cell.textLabel.text = [messageDict valueForKey:@"body"];

    if ([[messageDict valueForKey:@"message_type"] isEqualToString: @"alert"])
    {
    cell.textLabel.textColor = [UIColor redColor];
    }
    else if ([[messageDict valueForKey:@"message_type"] isEqualToString: @"friend_request"])
    {
        cell.textLabel.textColor = [UIColor greenColor];

    }
    
    else if ([[messageDict valueForKey:@"message_type"] isEqualToString: @"message"])
    {
        cell.textLabel.textColor = [UIColor orangeColor];
        
    }
    else if ([[messageDict valueForKey:@"message_type"] isEqualToString: @"walk_alert"]){
        cell.textLabel.textColor = [UIColor orangeColor];

    }
    else if ([[messageDict valueForKey:@"message_type"] isEqualToString: @"auto_message"]){
        cell.textLabel.textColor = [UIColor blueColor];
        
    }
    if([imageURL isEqualToString:@"none"]){
        [cell.imageView setImage:[UIImage imageNamed:@"git_icon_hover.png"]];
    }
    else{
        NSLog(@"yes");
        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageURL]]
                       placeholderImage:[UIImage imageNamed:@"git_icon_hover.png"]];
    }

    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 25;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dogID = [NSString alloc];
    NSString *messageType = [NSString alloc];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    for (int i = 0; i < messagesArray.count; i++){
        NSArray *messageArray = [messagesArray objectAtIndex:i];
        NSDictionary *messageDict = [messageArray objectAtIndex:0];
        if([[messageDict valueForKey:@"body"] isEqualToString:cell.text]){
            dogID = [messageDict valueForKey:@"sender_id"];
            messageType = [messageDict valueForKey:@"message_type"];
        }
    }
    if([messageType isEqualToString:@"friend_request"]){
    AENotificationViewController *notificationView = [[AENotificationViewController alloc] init];
    notificationView.notificationType = @"Friend Request";
    notificationView.notificationMessage = cell.text;
    notificationView.dogID = dogID;
    [self presentViewController:notificationView animated:YES completion:nil];
    }
    else if ([messageType isEqualToString:@"auto_message"]){
        
    }
    else if([messageType isEqualToString:@"message"]){
    AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
        UILabel *handleLabel = [cell.textLabel subviews][1];
        conversationView.senderImage = cell.imageView.image;
        conversationView.dogHandle = handleLabel.text;
        conversationView.dogID = dogID;
    [self presentViewController:conversationView animated:YES completion:nil];
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






@end
