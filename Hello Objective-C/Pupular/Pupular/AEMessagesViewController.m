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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    AEAppDelegate *objAppDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
//    if(objAppDelegate.applicationFromBackground)
//    {
//        applicationFromBackground = FALSE;
//        //do what u want.
//    }
//    NSLog(@"VIEW LOAD");
    [super viewDidLoad];
    //do stuff here
    if(&UIApplicationWillEnterForegroundNotification) { //needed to run on older devices, otherwise you'll get EXC_BAD_ACCESS
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(enteredForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }

    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [self loadUserInfo];
    // Do any additional setup after loading the view from its nib.
}

- (void)enteredForeground:(NSNotification*) not
{
    NSLog(@"HERE WE GO");
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/messages?dog_id=%@",[userInfo valueForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];}

-(void)viewWillAppear:(BOOL)animated{
    [spinner startAnimating];
    [self loadUserInfo];
    _isEditing = NO;
    [self startTimer];
    NSLog(@"VIEW WILL APPEAR");
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
    if([sender isOn]){
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/walk_alert?dog_id=%@",[userInfo objectForKey:@"dog_id"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [_locationController.locationManager startUpdatingLocation];
        [userInfo setValue:@"true" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    else{
        
        [_locationController.locationManager stopUpdatingLocation];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/deactivate?email=%@",[userInfo objectForKey:@"email"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [userInfo setValue:@"false" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self stopTimer];

}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"VIEW DID APPEAR");


}

- (void) startTimer
{
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
    NSLog(@"got that fire man");
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    messagesArray = appDelegate.all_messages;
    if(![self.tableView isEditing]){
    [self.tableView reloadData];
    }
    [spinner stopAnimating];
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
        NSString *dateString = [dateFormat stringFromDate:today];
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
    NSLog(@"test 1");
    NSLog(@"dem subview jowns %@",[cell.contentView subviews]);
    UILabel *messageText = [[cell.contentView subviews][1] subviews][2];
    NSLog(@"test 2");
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
    NSLog(@"OTHER DOG JOWN %@",otherDog);
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/has_been_read?message_id=%@",messageID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    if([messageType isEqualToString:@"friend_request"]){
    AENotification2ViewController *notificationView = [[AENotification2ViewController alloc] init];
    notificationView.notificationType = @"Friend Request";
    notificationView.notificationMessage = messageText.text;
    notificationView.locationController = _locationController;
    notificationView.dogID = otherDog;
    notificationView.isFriend = NO;
        notificationView.dogHandle = [NSString stringWithFormat:@"%@",dogHandle];
    
    [self presentViewController:notificationView animated:NO completion:nil];
    }
    else if ([messageType isEqualToString:@"auto_message"] || [messageType isEqualToString:@"request_accepted"]){
        
        AENotification2ViewController *notificationView = [[AENotification2ViewController alloc] init];
        
        notificationView.notificationType = @"Alert";
        notificationView.notificationMessage = messageText.text;
        notificationView.locationController = _locationController;
        notificationView.dogID = otherDog;
        notificationView.isFriend = YES;
            notificationView.dogHandle = dogHandle;
        [self presentViewController:notificationView animated:NO completion:nil];
    }
    else if([messageType isEqualToString:@"message"]){
    AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
        UILabel *handleLabel = [[cell.contentView subviews][1] subviews][1];
        conversationView.senderImage = cell.imageView.image;
        conversationView.locationController = _locationController;
        conversationView.dogHandle = handleLabel.text;
        conversationView.dogID = otherDog;
    [self presentViewController:conversationView animated:NO completion:nil];
    }
    else if([messageType isEqualToString:@"walk_alert"]){
        AENotification2ViewController *notificationView = [[AENotification2ViewController alloc] init];

        notificationView.notificationType = @"Walk Alert";
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
