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
#import "AEAppDelegate.h"


@interface AEMessagesViewController ()

@end

@implementation AEMessagesViewController
@synthesize tableView,spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        messagesArray = [[NSMutableArray alloc] init];
        self.title = @"Messages";
        _fillerView = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.allMessages){
        messagesArray = appDelegate.allMessages;
    }
    if(&UIApplicationWillEnterForegroundNotification) { //needed to run on older devices, otherwise you'll get EXC_BAD_ACCESS
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(enteredForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [self loadUserInfo];
}

- (void)enteredForeground:(NSNotification*) not
{
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/messages?dog_id=%@",[userInfo valueForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"VIEW WILL APPEAR");
    [spinner startAnimating];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];

    [self loadUserInfo];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _allDogs = appDelegate.allDogs;
    [self.tableView reloadData];
    _isEditing = NO;
    [self startTimer];
    if([userInfo valueForKey:@"is_active"]){
        if([[userInfo valueForKey:@"is_active"] isEqualToString:@"true"]){
            [_trackingSwitch setOn:YES];
        }
        else{
            [_trackingSwitch setOn:NO];
        }
    }
}

-(void)notificationTargetTapped{

}


-(IBAction)trackingSwitch:(id)sender{
    [self.delegate switched];

}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"VIEW WILL DISAPPEAR");
    [self stopTimer];
}

- (void) startTimer
{
    NSLog(@"timer started");
    self.messageTime = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(timerFired:)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void) stopTimer
{
    [self.messageTime invalidate];
}

- (void) timerFired:(NSTimer*)theTimer
{
    [self loadUserInfo];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.allMessages){
        messagesArray = appDelegate.allMessages;
    }
    if(messagesArray.count == 0){
        self.tableView.hidden = YES;
        if(_fillerView == nil){
            UIView *messageFiller = [[[[NSBundle mainBundle] loadNibNamed:@"AEMessageViewFiller" owner:self options:nil] objectAtIndex:0] initWithFrame:CGRectMake(200, 400, 2, 3)];
            UIView *frameSauce = [[UIView alloc] initWithFrame:CGRectMake(0,80,200,300)];
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
    if(![self.tableView isEditing]){
    [self.tableView reloadData];
    }
    [spinner stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc]init];
    menuView.locationController = _locationController;
    [self presentViewController:menuView animated:YES completion:nil];
}

-(IBAction)newMessage:(id)sender{
    AENewMessageViewController *newMessage = [[AENewMessageViewController alloc] init];
    newMessage.delegate = self;
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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    return NO;
}

-(void)checkForDeletedMessages{
    NSMutableArray *deletedMessages = [userInfo objectForKey:@"deletedMessages"];
    for(int i = 0; i < messagesArray.count; i ++){
        NSDictionary *thisMessage = [messagesArray objectAtIndex:i];
        NSString *thisMessageID = [thisMessage objectForKey:@"id"];
        for(int v = 0; v < deletedMessages.count; v++){
            NSString *thisDeletedMessageOnFile = [deletedMessages objectAtIndex:v];
            if([thisMessageID isEqualToString:thisDeletedMessageOnFile]){
                [messagesArray removeObjectAtIndex:i];
                break;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableDictionary *messageDict = [messagesArray objectAtIndex:indexPath.row][0];
        NSString *deletedMessageID = [messageDict valueForKey:@"id"];
        NSMutableArray *deletedMessages;
        if([userInfo valueForKey:@"deletedMessages"]){
            deletedMessages = [userInfo valueForKey:@"deletedMessages"];
            [deletedMessages addObject:deletedMessageID];
        }
        else {
            deletedMessages = [NSMutableArray arrayWithObject:[messageDict valueForKey:@"id"]];
        }
        [userInfo setObject:deletedMessages forKey:@"deletedMessages"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
        [messagesArray removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    return [difference day];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [spinner stopAnimating];
    static NSString *CellIdentifier = @"CustomTableCell";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    if([[cell.contentView subviews] count] > 1){
        UIView *currentView = [[cell.contentView subviews] objectAtIndex:1];
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
    //    //cell.thumbnailImageView.image = [UIImage imageNamed:recipe.image];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIView *cellSubView = [[UIView alloc] initWithFrame:CGRectMake(80,0,240,80)];
    UILabel *sender_tag = [[UILabel alloc] initWithFrame:CGRectMake(0,20,100,10)];
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0,50,150,15)];
    message.text = [messageDict valueForKey:@"body"];
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(130,20,100,10)];
    UILabel *reader = [[UILabel alloc] initWithFrame:CGRectMake(200,50,20,20)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
    imageView.image = [UIImage imageNamed:@"readIndicator.png"];
    [reader addSubview:imageView];
    [cellSubView addSubview:date];
    [cellSubView addSubview:sender_tag];
    [cellSubView addSubview:message];
    [date setFont:[UIFont fontWithName:@"Arial-ItalicMT" size:10]];
    date.textColor = [UIColor grayColor];
    [sender_tag setFont:[UIFont fontWithName:@"Avenir Next" size:10]];
    sender_tag.textColor = [UIColor grayColor];
    [message setFont:[UIFont fontWithName:@"Avenir Next" size:13]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSDate *dateField = [formatter dateFromString:[NSString stringWithFormat:@"%@",[messageDict valueForKey:@"created_at"]]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:dateField];
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d"];
    NSString *dateString = [dateFormat stringFromDate:dateField];
    
    int timeDifference = [self daysBetweenDate:[NSDate date] andDate:dateField];
    if(timeDifference < 0){
        date.text = dateString;
    }
    else {
        [dateFormat setDateFormat:@"h:mm a"];
        NSString *dateString = [dateFormat stringFromDate:dateField];
        date.text = dateString;
        
    }
    date.textAlignment = NSTextAlignmentRight;
    sender_tag.text = [messageArray objectAtIndex:1];
    NSString *imageURL = [messageArray objectAtIndex:2];
    NSString *senderID = [messageDict valueForKey:@"sender_id"];
    NSString *dogID = [userInfo valueForKey:@"dog_id"];
    NSString *messageType = [messageDict valueForKey:@"message_type"];
    if ([[messageDict objectForKey:@"read"] boolValue] == NO)
    {
        if(([senderID intValue] == [dogID intValue]) && ([messageType isEqualToString:@"message"])){
            
        }
        else{
            [cellSubView addSubview:reader];
            
        }
        
        
    }
    if([imageURL isEqualToString:@"none"]){
        [cell.imageView setImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    }
    else{
        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageURL]]
                       placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    }
    
    cell.imageView.clipsToBounds = YES;
    cell.imageView.backgroundColor = [UIColor grayColor];
    cell.imageView.layer.cornerRadius = 25;
    
    [cell.imageView.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
    [cell.imageView.layer setBorderWidth: 1.0];
    [cell.contentView addSubview:cellSubView];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dogID = [[NSString alloc] init];
    NSString *otherDog = [[NSString alloc] init];
    NSString *messageType = [[NSString alloc] init];
    NSString *messageID = [[NSString alloc] init];
    NSString *dogHandle = [[NSString alloc] init];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *messageText = [[cell.contentView subviews][1] subviews][2];
    for (int i = 0; i < messagesArray.count; i++){
        NSArray *messageArray = [messagesArray objectAtIndex:i];
        NSDictionary *messageDict = [messageArray objectAtIndex:0];
        
        if([[messageDict valueForKey:@"body"] isEqualToString:messageText.text]){
            NSString *senderID = [messageDict valueForKey:@"sender_id"];
            NSString *receiverID = [messageDict valueForKey:@"receiver_id"];
            NSString *dogID = [userInfo valueForKey:@"dog_id"];
            if([senderID intValue] == [dogID intValue])
            {
                otherDog = receiverID;
            }
            else{
                otherDog = senderID;
            }
            
            messageType = [messageDict valueForKey:@"message_type"];
            messageID = [messageDict valueForKey:@"id"];
            dogHandle = [messageArray objectAtIndex:1];
        }
    }
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/has_been_read?message_id=%@",messageID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    if([messageType isEqualToString:@"friend_request"]){
        AENotification2ViewController *notificationView = [[AENotification2ViewController alloc] init];
        notificationView.notificationType = @"Pack Request";
        notificationView.notificationMessage = messageText.text;
        notificationView.locationController = _locationController;
        notificationView.dogID = otherDog;
        notificationView.isFriend = NO;
        notificationView.dogHandle = [NSString stringWithFormat:@"%@",dogHandle];
        
        [self presentViewController:notificationView animated:NO completion:nil];
    }
    else if ([messageType isEqualToString:@"auto_message"] || [messageType isEqualToString:@"request_accepted"]){
        
        AENotification2ViewController *notificationView = [[AENotification2ViewController alloc] init];
        
        notificationView.notificationType = @"Pack Alert";
        notificationView.notificationMessage = messageText.text;
        notificationView.locationController = _locationController;
        notificationView.dogID = otherDog;
        notificationView.cellImage = cell.imageView.image;
        notificationView.isFriend = YES;
        notificationView.dogHandle = dogHandle;
        [self presentViewController:notificationView animated:NO completion:nil];
    }
    else if([messageType isEqualToString:@"message"]){
        AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
        UILabel *handleLabel = [[cell.contentView subviews][1] subviews][1];
        conversationView.delegate = self;
        conversationView.senderImage = cell.imageView.image;
        conversationView.locationController = _locationController;
        conversationView.dogHandle = handleLabel.text;
        conversationView.dogID = otherDog;
        [self presentViewController:conversationView animated:NO completion:nil];
    }
    else if([messageType isEqualToString:@"walk_alert"]){
        AENotification2ViewController *notificationView = [[AENotification2ViewController alloc] init];
        notificationView.notificationType = @"Wag Alert";
        notificationView.notificationMessage = messageText.text;
        notificationView.locationController = _locationController;
        notificationView.senderThumb = cell.imageView.image;
        notificationView.dogID = otherDog;
        notificationView.isFriend = YES;
        notificationView.dogHandle = dogHandle;
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
