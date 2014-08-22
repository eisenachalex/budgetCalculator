//
//  AENotification2ViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 7/12/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//



#import "AENotification2ViewController.h"
#import "AEMenuViewController.h"
#import "AETargetMapViewController.h"
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
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.imageView addGestureRecognizer:singleFingerTap];
    
    //The event handling method

    dogInfo = [[NSDictionary alloc] init];
    NSURLRequest *profile_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/retrieve_profile_photo?dog_id=%@",_dogID]]];
    NSURLConnection *profile = [[NSURLConnection alloc] initWithRequest:profile_request delegate:self];
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 86.37;
    self.imageView.userInteractionEnabled = YES;

    // Do any additional setup after loading the view from its nib.
    
}




- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    AEFriendProfileViewController *profileView = [[AEFriendProfileViewController alloc] init];
    profileView.dogID = _dogID;
    profileView.view.translatesAutoresizingMaskIntoConstraints = YES;
    profileView.isFriend = _isFriend;
    profileView.dogHandle = _dogHandle;
    profileView.isMine = NO;
    [self presentViewController:profileView animated:NO completion:nil];
}


-(void)viewWillAppear:(BOOL)animated{
    [self loadUserInfo];
    if([self.notificationType isEqualToString:@"Friend Request"]){
        [self.actionButton1 setTitle:@"Accept Request" forState:UIControlStateNormal];
        [self.actionButton2 setTitle:@"Decline Request" forState:UIControlStateNormal];
        
        [self.notificationTitle setText:self.notificationMessage];
    }
    
    if([self.notificationType isEqualToString:@"Auto Message"]){
        [self.actionButton1 setTitle:@"Message" forState:UIControlStateNormal];
        [self.actionButton2 setTitle:@"Pack" forState:UIControlStateNormal];
        [self.notificationTitle setText:self.notificationMessage];
    }
    
    
    if([self.notificationType isEqualToString:@"Walk Alert"]){
        [self.actionButton1 setTitle:@"Message" forState:UIControlStateNormal];
        [self.actionButton2 setTitle:@"Track" forState:UIControlStateNormal];
        
        [self.notificationTitle setText:self.notificationMessage];
    }
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

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(IBAction)actionButton1:(id)sender{
    if([[sender currentTitle] isEqualToString:@"Accept Request"]){
        NSLog(@"is it firing the jownt");
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
        conversationView.senderImage = _senderThumb;
        conversationView.dogHandle = handleLabel.text;
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
        UITabBarController *tabBarController = appDelegate.tabBarController;
        [tabBarController setSelectedIndex:0];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if([[sender currentTitle] isEqualToString:@"Pack"]){
        AEBuddiesViewController *buddiesView = [[AEBuddiesViewController alloc] init];
        buddiesView.foreign_dog_id = _dogID;
        buddiesView.locationController = _locationController;
        [self presentViewController:buddiesView animated:NO completion:nil];
        
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
    NSLog(@"here is the user info %@", userInfo);
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    NSLog(@"path %@",paths);
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
    if([newJSON objectForKey:@"profile_photo"])
    {
        NSLog(@"firing %@",[newJSON objectForKey:@"profile_photo"]);
        [_imageView setImageWithURL:[NSURL URLWithString:[newJSON objectForKey:@"profile_photo"]]
                  placeholderImage:[UIImage imageNamed:@"filler_icon.png"]];
        
    }
    
    
}


@end