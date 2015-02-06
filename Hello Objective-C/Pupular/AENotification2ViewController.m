//
//  AENotification2ViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 7/12/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//



#import "AENotification2ViewController.h"
#import "AEMenuViewController.h"
#import "AEAboutViewController.h"
#import "UIImageView+WebCache.h"
#import "AEBuddiesViewController.h"
#import "AEFriendProfileViewController.h"
#import "AEConvoViewController.h"
#import "AEAppDelegate.h"

@interface AENotification2ViewController ()

@end

@implementation AENotification2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _isFriend = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUserInfo];
    _navBar.topItem.title = _notificationType;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.imageView addGestureRecognizer:singleFingerTap];
    dogInfo = [[NSDictionary alloc] init];

    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 80;
    [self.imageView.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
    [self.imageView.layer setBorderWidth: 3.0];
    self.imageView.userInteractionEnabled = YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    AEFriendProfileViewController *profileView = [[AEFriendProfileViewController alloc] init];
    profileView.dogID = _dogID;
    profileView.view.translatesAutoresizingMaskIntoConstraints = YES;
    [self presentViewController:profileView animated:NO completion:nil];
}


-(void)viewWillAppear:(BOOL)animated{
    [self loadUserInfo];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _allDogs = appDelegate.allDogs;
    NSString *dogID = _dogID;
    _dog = [_allDogs objectForKey:[NSString stringWithFormat:@"%@",dogID]];
    
    NSString *imageURl = [_dog valueForKey:@"photo_list"][0];
    [_imageView setImageWithURL:[NSURL URLWithString:imageURl]
               placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
    
    
    if([self.notificationType isEqualToString:@"Pack Request"]){
        [self.actionButton1 setTitle:@"Accept Request" forState:UIControlStateNormal];
        [self.actionButton2 setTitle:@"Decline Request" forState:UIControlStateNormal];
        [self.actionButton1 setBackgroundImage:[UIImage imageNamed:@"pupular_accept_button.png"] forState:UIControlStateNormal];
        [self.actionButton2 setBackgroundImage:[UIImage imageNamed:@"pupular_decline_button.png"] forState:UIControlStateNormal];
        [self.notificationTitle setText:self.notificationMessage];
    }
    
    if([self.notificationType isEqualToString:@"Pack Alert"]){
      [self.actionButton1 setTitle:@"Message" forState:UIControlStateNormal];
        [self.actionButton1 setBackgroundImage:[UIImage imageNamed:@"pupular_message_button.png"] forState:UIControlStateNormal];
        [self.actionButton2 setBackgroundImage:[UIImage imageNamed:@"pupular_pack_button.png"] forState:UIControlStateNormal];
        [self.notificationTitle setText:self.notificationMessage];
        [self.actionButton2 setTitle:@"Pack" forState:UIControlStateNormal];
    }
    if([self.notificationType isEqualToString:@"Wag Alert"]){
        [self.actionButton1 setTitle:@"Message" forState:UIControlStateNormal];
        [self.actionButton2 setTitle:@"Track" forState:UIControlStateNormal];
        [self.actionButton1 setBackgroundImage:[UIImage imageNamed:@"pupular_message_button.png"] forState:UIControlStateNormal];
        [self.actionButton2 setBackgroundImage:[UIImage imageNamed:@"pupular_track_button.png"] forState:UIControlStateNormal];
        [self.notificationTitle setText:self.notificationMessage];
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

-(IBAction)actionButton1:(id)sender{
    if([[sender currentTitle] isEqualToString:@"Accept Request"]){
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/accept_request?dog_id=%@&friend_id=%@",_dogID,[userInfo valueForKey:@"dog_id"]]]];
        NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
        [self dismissViewControllerAnimated:NO completion:nil];
        
    }
    if([[sender currentTitle] isEqualToString:@"Message"]){
        UILabel *handleLabel = [[UILabel alloc] init];
        handleLabel.text = [dogInfo valueForKey:@"handle"];
        NSString *photoURL = [dogInfo objectForKey:@"photo"];
        AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
        conversationView.locationController = _locationController;
        conversationView.senderImage = _cellImage;
        conversationView.dogHandle = [_dog valueForKey:@"handle"];
        conversationView.dogID = _dogID;
        [self presentViewController:conversationView animated:NO completion:nil];
    }
}

-(IBAction)actionButton2:(id)sender{
    if([[sender currentTitle] isEqualToString:@"Decline Request"]){
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/decline_request?dog_id=%@&friend_id=%@",_dogID,[userInfo valueForKey:@"dog_id"]]]];
        NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    if([[sender currentTitle] isEqualToString:@"Track"]){
        AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.targetID = _dogID;
        appDelegate.mapHasTarget = YES;
        [[appDelegate.tabBarController.viewControllers objectAtIndex:0] viewWillAppear:YES];
        [appDelegate.tabBarController setSelectedIndex:0];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    if([[sender currentTitle] isEqualToString:@"Pack"]){
        AEBuddiesViewController *buddiesView = [[AEBuddiesViewController alloc] init];
        buddiesView.locationController =_locationController;
        buddiesView.dogID = [_dog valueForKey:@"id"];
        [self presentViewController:buddiesView animated:NO completion:nil];
    }
}
- (void)loadUserInfo {
    NSString *filePath = [self pathForUserInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    }
    else {
        userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setValue:@"empty" forKey:@"email"];
    }
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
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
}


@end