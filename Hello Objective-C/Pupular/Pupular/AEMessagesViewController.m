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
#import "AENotification2ViewController.h"
#import "AEConvoViewController.h"
#import "UIImageView+WebCache.h"

@interface AEMessagesViewController ()

@end

@implementation AEMessagesViewController
@synthesize tableView,spinner;

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
    NSLog(@"VIEW LOAD");
    [self loadUserInfo];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [spinner startAnimating];
    NSLog(@"VIEW WILL APPEAR");

    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/messages?dog_id=%@",[userInfo valueForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"VIEW DID APPEAR");

    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/messages?dog_id=%@",[userInfo valueForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc]init];
    menuView.locationController = _locationController;
    [self presentViewController:menuView animated:YES completion:nil];
}

-(IBAction)newMessage:(id)sender{
    AENewMessageViewController *newMessage = [[AENewMessageViewController alloc] init];
    newMessage.locationController = _locationController;
    [self presentViewController:newMessage animated:NO completion:nil];
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
    [spinner stopAnimating];
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    if([newJSON objectForKey:@"messages"])
    {
        messagesArray = [[NSMutableArray alloc] init];
        for(int i = 0; i < [[newJSON objectForKey:@"messages"] count]; i++)
        {
        NSDictionary *messageObject = [newJSON objectForKey:@"messages"][i];
        [messagesArray addObject:messageObject];
        }
    }
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
    return 80.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSString *messageID = [[NSString alloc] init];
        NSString *sender_id = [[NSString alloc] init];
        NSString *receiver_id = [[NSString alloc] init];
        UILabel *messageText = [[cell.contentView subviews][1] subviews][2];
        NSLog(@"message text %@",messageText.text);
        for (int i = 0; i < messagesArray.count; i++){
            NSArray *messageArray = [messagesArray objectAtIndex:i];
            NSDictionary *messageDict = [messageArray objectAtIndex:0];
            NSLog(@"messagedict %@",[messageDict valueForKey:@"body"]);
            if([[messageDict valueForKey:@"body"] isEqualToString:messageText.text]){
                NSLog(@"no fire");
                messageID = [messageDict valueForKey:@"id"];
                sender_id = [messageDict valueForKey:@"sender_id"];
                receiver_id = [messageDict valueForKey:@"receiver_id"];
            }
        }

        NSLog(@"message id jowns %@",messageID);
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/delete_message?message_id=%@",messageID]]];
        NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
        [messagesArray removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }


}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    

    for(int i = 0; i < [cell.contentView.subviews count]; i++){

        UIView *currentView = [[cell.contentView subviews] objectAtIndex:i];
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
    UIView *cellSubView = [[UIView alloc] initWithFrame:CGRectMake(80,0,240,80)];
    
    UILabel *sender_tag = [[UILabel alloc] initWithFrame:CGRectMake(0,20,100,10)];
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0,50,150,10)];
    message.text = [messageDict valueForKey:@"body"];
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(100,20,100,10)];
    UILabel *reader = [[UILabel alloc] initWithFrame:CGRectMake(200,40,20,20)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,20,20)];
    imageView.image = [UIImage imageNamed:@"git_icon_hover.png"];
    [reader addSubview:imageView];
    [cellSubView addSubview:date];

    [cellSubView addSubview:sender_tag];
    [cellSubView addSubview:message];

    reader.textColor = [UIColor blueColor];
    [reader setFont:[UIFont fontWithName:@"Arial" size:30]];

    [date setFont:[UIFont fontWithName:@"Arial" size:10]];
    [sender_tag setFont:[UIFont fontWithName:@"Arial" size:10]];
    [message setFont:[UIFont fontWithName:@"Arial" size:13]];
    date.text = [messageDict valueForKey:@"created_at"];
    NSTimeInterval unixTimeStamp = 34;
    sender_tag.text = [messageArray objectAtIndex:1];
    NSString *imageURL = [messageArray objectAtIndex:2];

    if ([[messageDict objectForKey:@"read"] boolValue] == NO)
    {
        [cellSubView addSubview:reader];


    }
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
        [cell.imageView setImage:[UIImage imageNamed:@"filler_icon.png"]];
    }
    else{
        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageURL]]
                       placeholderImage:[UIImage imageNamed:@"filler_icon.png"]];
    }

    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 25;
    [cell.contentView addSubview:cellSubView];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dogID = [[NSString alloc] init];
    NSString *messageType = [[NSString alloc] init];
    NSString *messageID = [[NSString alloc] init];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"test 1");
    NSLog(@"dem subview jowns %@",[cell.contentView subviews]);
    UILabel *messageText = [[cell.contentView subviews][1] subviews][2];
    NSLog(@"test 2");
    for (int i = 0; i < messagesArray.count; i++){
        NSArray *messageArray = [messagesArray objectAtIndex:i];
        NSDictionary *messageDict = [messageArray objectAtIndex:0];

        if([[messageDict valueForKey:@"body"] isEqualToString:messageText.text]){
            dogID = [messageDict valueForKey:@"sender_id"];
            messageType = [messageDict valueForKey:@"message_type"];
            messageID = [messageDict valueForKey:@"id"];
        }
    }
    
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/has_been_read?message_id=%@",messageID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    if([messageType isEqualToString:@"friend_request"]){
    AENotification2ViewController *notificationView = [[AENotification2ViewController alloc] init];
    notificationView.notificationType = @"Friend Request";
    notificationView.notificationMessage = messageText.text;
    notificationView.locationController = _locationController;
    notificationView.dogID = dogID;
    [self presentViewController:notificationView animated:NO completion:nil];
    }
    else if ([messageType isEqualToString:@"auto_message"]){
        
        AENotification2ViewController *notificationView = [[AENotification2ViewController alloc] init];
        
        notificationView.notificationType = @"Auto Message";
        notificationView.notificationMessage = messageText.text;
        notificationView.locationController = _locationController;
        notificationView.dogID = dogID;
        [self presentViewController:notificationView animated:NO completion:nil];
    }
    else if([messageType isEqualToString:@"message"]){
    AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
        UILabel *handleLabel = [[cell.contentView subviews][1] subviews][1];
        conversationView.senderImage = cell.imageView.image;
        conversationView.locationController = _locationController;
        conversationView.dogHandle = handleLabel.text;
        conversationView.dogID = dogID;
    [self presentViewController:conversationView animated:NO completion:nil];
    }
    else if([messageType isEqualToString:@"walk_alert"]){
        AENotification2ViewController *notificationView = [[AENotification2ViewController alloc] init];

        notificationView.notificationType = @"Walk Alert";
        notificationView.notificationMessage = messageText.text;
        notificationView.locationController = _locationController;
        notificationView.dogID = dogID;
        [self presentViewController:notificationView animated:NO completion:nil];
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
