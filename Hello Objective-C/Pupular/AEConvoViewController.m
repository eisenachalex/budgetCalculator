//
//  AEConvoViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//
#import "AEConvoViewController.h"
#import "AEAppDelegate.h"
#import "AEMenuViewController.h"
#import "AEActiveFriendsViewController.h"
#import "UIImageView+WebCache.h"
#import "AEMessagesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AEAppDelegate.h"


@interface AEConvoViewController ()

@end

@implementation AEConvoViewController
@synthesize tableView,scrollView,toolBar,navTitle,senderImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        messagesArray = [[NSMutableArray alloc]init];
        senderImage = [UIImage imageNamed:@"pupular_dog_avatar_thumb.png"];
        _firstRequest = YES;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


-(void)textFieldDidChange:(id)sender{
    _keyBoardVisible = YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.messageResponse addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        [self.messageResponse becomeFirstResponder];
    }
    else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    [self loadUserInfo];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 350, 150)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 20, 125, 125)];
    imageView.tag = 13;
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = 60;
    NSURLRequest *profile_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://dry-shelf-9195.herokuapp.com/retrieve_profile_photo?dog_id=%@",_dogID]]];
    NSURLConnection *profile = [[NSURLConnection alloc] initWithRequest:profile_request delegate:self];
    [headerView addSubview:imageView];
    self.tableView.tableHeaderView = headerView;
    float y = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - self.toolBar.frame.size.height;
    [self.toolBar setFrame:CGRectMake(0, y+10, self.toolBar.bounds.size.width, self.toolBar.bounds.size.height)];
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://dry-shelf-9195.herokuapp.com/conversation?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    self.messageResponse.delegate = self;
    _senderImageView.clipsToBounds = YES;
    _senderImageView.layer.cornerRadius = 30;
    _senderImageView.image = senderImage;
}

-(void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    NSLog(@"user id %@",[userInfo valueForKey:@"dog_id"]);
    _firstRequest = YES;
    _keyBoardVisible = NO;
    navTitle.title = _dogHandle;
    [self startTimer];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _allDogs = appDelegate.allDogs;
    [appDelegate stopTimer];
    [tableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"disappear jowns");
    [self stopTimer];
    [super viewWillDisappear:animated];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate startTimer];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:NO completion:nil];}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(IBAction)sendMessage:(id)sender{
    _keyBoardVisible = NO;
    _sendMessageButton.userInteractionEnabled = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://dry-shelf-9195.herokuapp.com/new_message?sender_id=%@&receiver_id=%@&message_type=message&body=%@",[userInfo valueForKey:@"dog_id"],_dogID,[self.messageResponse.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                            error:nil];
    [_spinner stopAnimating];
    if([newJSON objectForKey:@"total_convo"])
    {
        messagesArray = [[NSMutableArray alloc] init];
        for(int i = 0; i < [[newJSON objectForKey:@"total_convo"] count]; i++)
        {
            NSDictionary *messageObject = [newJSON objectForKey:@"total_convo"][i];
            [messagesArray addObject:messageObject];
        }
        [self.tableView reloadData];
        [self.messageResponse setText:@""];
        if([messagesArray count] > 0){
            if(_firstRequest){

                _firstRequest = NO;
            }
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messagesArray count]-1 inSection: 1-1];
        [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        }


    }
    if([newJSON objectForKey:@"message"]){
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://dry-shelf-9195.herokuapp.com/conversation?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
        NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
        _sendMessageButton.userInteractionEnabled = YES;
    }
    if([newJSON objectForKey:@"profile_photo"]){
        UIImageView *myImageView = (UIImageView *)[self.tableView.tableHeaderView viewWithTag:13];
        [myImageView.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
        [myImageView.layer setBorderWidth: 3.0];
        [myImageView setImageWithURL:[NSURL URLWithString:[newJSON objectForKey:@"profile_photo"]]
                       placeholderImage:[UIImage imageNamed:@"pupular_avatar_thumb.png"]];
        _thumbImage = myImageView.image;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messagesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *user = nil;
    NSDictionary *message = [messagesArray objectAtIndex:indexPath.row];
    cell.imageView.image = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *friendDict = [_allDogs objectForKey:[NSString stringWithFormat:@"%@",_dogID]];
    NSString *imageURL = [friendDict valueForKey:@"photo_list"][1];
    cell.textLabel.text = [message valueForKey:@"body"];
    [cell.textLabel setFont:[UIFont fontWithName:@"Arial" size:12]];
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.numberOfLines = 0;
    NSString *message_id = [message valueForKey:@"sender_id"];
    if([message_id intValue] == [[userInfo valueForKey:@"dog_id"] intValue] )
    {
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    }
    else {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageURL]]
                       placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];    }
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 25;
    [cell.imageView.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
    [cell.imageView.layer setBorderWidth: 1.0];
    return cell;
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


- (void) startTimer
{
    self.myTime = [NSTimer scheduledTimerWithTimeInterval:1
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
    
    [self loadUserInfo];
    if(!_keyBoardVisible){
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://dry-shelf-9195.herokuapp.com?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    }
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}

@end
