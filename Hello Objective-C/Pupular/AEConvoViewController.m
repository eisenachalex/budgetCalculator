//
//  AEConvoViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//
#import "AEConvoViewController.h"
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

    [self loadUserInfo];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 350, 150)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 20, 125, 125)];
    imageView.tag = 13;
    self.navigationController.navigationBar.topItem.title = @"BOOM";
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = 60;
    NSURLRequest *profile_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/retrieve_profile_photo?dog_id=%@",_dogID]]];
    NSURLConnection *profile = [[NSURLConnection alloc] initWithRequest:profile_request delegate:self];
    [headerView addSubview:imageView];
//    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 10)];
//    labelView.text = @"DogHandle";
//    [headerView addSubview:labelView];
    self.tableView.tableHeaderView = headerView;
    float y = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - self.toolBar.frame.size.height;
    [self.toolBar setFrame:CGRectMake(0, y+10, self.toolBar.bounds.size.width, self.toolBar.bounds.size.height)];

    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/conversation?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    // Do any additional setup after loading the view from its nib.
    self.messageResponse.delegate = self;
    _senderImageView.clipsToBounds = YES;
    _senderImageView.layer.cornerRadius = 30;
    _senderImageView.image = senderImage;



}





-(void)viewWillAppear:(BOOL)animated  {
    
    [super viewWillAppear:YES];
    _firstRequest = YES;
    navTitle.title = _dogHandle;
    [self startTimer];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate stopTimer];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
    [tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopTimer];
    [super viewWillDisappear:animated];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate startTimer];
//    [self stopTimer];
//    // unregister for keyboard notifications while not visible.
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillShowNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillHideNotification
//                                                  object:nil];
}
//
-(void)keyboardWillShow {


}
//
//-(void)keyboardWillHide {
//    float y = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - self.toolBar.frame.size.height;
//    [self.toolBar setFrame:CGRectMake(0, y+13, self.toolBar.bounds.size.width, self.toolBar.bounds.size.height)];
//    _keyBoardVisible = FALSE;
//}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    float y = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - self.toolBar.frame.size.height;
    float tableY = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - self.tableView.frame.size.height;
    [self.toolBar setFrame:CGRectMake(0, y-215, self.toolBar.bounds.size.width, self.toolBar.bounds.size.height)];
    [self.tableView setFrame:CGRectMake(0, tableY-300, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    if([messagesArray count] > 1) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messagesArray count]-1 inSection: 1-1];
        [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }


//    self.tableView.userInteractionEnabled = NO;
    _keyBoardVisible = YES;

 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{

    NSLog(@"JOWNNN");
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}



- (IBAction)cancel:(id)sender {

    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];

    [self dismissViewControllerAnimated:NO completion:nil];


}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"okay");
    return YES;
}

-(IBAction)sendMessage:(id)sender{
    _sendMessageButton.userInteractionEnabled = NO;

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/new_message?sender_id=%@&receiver_id=%@&message_type=message&body=%@",[userInfo valueForKey:@"dog_id"],_dogID,[self.messageResponse.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
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
                NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messagesArray count]-1 inSection: 1-1];
                [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
                _firstRequest = NO;
            }
        }
      //  [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    }
    if([newJSON objectForKey:@"message"]){
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/conversation?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
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
    

    NSLog(@"MESASGAGDSAGSD %@",messagesArray);




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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Display recipe in the table cell
    NSString *user = nil;
    NSDictionary *message = [messagesArray objectAtIndex:indexPath.row];
    //cell.thumbnailImageView.image = [UIImage imageNamed:recipe.image];
    cell.imageView.image = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [message valueForKey:@"body"];
    [cell.textLabel setFont:[UIFont fontWithName:@"Arial" size:12]];
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.numberOfLines = 0;
    NSString *message_id = [message valueForKey:@"sender_id"];
    NSLog(@"message id %@",message_id);
    NSLog(@"and dog... id %@", [userInfo valueForKey:@"dog_id"]);

    if([message_id intValue] == [[userInfo valueForKey:@"dog_id"] intValue] )
    {
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    }
    else {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.imageView.image = senderImage;
    }
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
        NSLog(@"no key");
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/conversation?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    }
}




- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    NSLog(@"path %@",paths);
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}


@end
