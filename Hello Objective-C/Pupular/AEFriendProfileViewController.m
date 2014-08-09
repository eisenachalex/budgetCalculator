//
//  AEProfileViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEMenuViewController.h"
#import "AEFriendProfileViewController.h"
#import "AEConvoViewController.h"
#import "AEMessagesViewController.h"
#import "AEAdditionView.h"
#import "UIImageView+WebCache.h"
#import "AEBuddiesViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AEAboutViewController.h"
#import "AELogInViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AEFriendProfileViewController ()

@end

@implementation AEFriendProfileViewController
@synthesize imageView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _navTitle.title = _dogHandle;

    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 85;
    [self.activity startAnimating];
    self.activity.hidesWhenStopped = YES;

    
    ;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self loadUserInfo];
    if(self.isFriend){
        [self.actionButton setTitle:@"Message" forState:UIControlStateNormal];
        
    }
    else if(self.isMine){
        [self.actionButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
    }
    else {
        [self.actionButton setTitle:@"Request" forState:UIControlStateNormal];
        
    }
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/profile?dog_id=%@",_dogID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    
    NSURLRequest *profile_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/retrieve_profile_photo?dog_id=%@",_dogID]]];
    NSURLConnection *profile = [[NSURLConnection alloc] initWithRequest:profile_request delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back:(id)sender{

    [self dismissViewControllerAnimated:NO completion:nil];
}


- (IBAction)buddies:(id)sender {
    AEBuddiesViewController *buddiesView = [[AEBuddiesViewController alloc] init];
    buddiesView.foreign_dog_id = _dogID;
    buddiesView.locationController = _locationController;
    [self presentViewController:buddiesView animated:NO completion:nil];
}





-(IBAction)cancel:(id)sender{
    
}



-(IBAction)actionButton:(id)sender{
    if([[sender currentTitle] isEqualToString:@"Edit Profile"])
    {
    }
    else if([[sender currentTitle] isEqualToString:@"Request"])
    {
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/friend_request?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
        NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
        AEMessagesViewController *messagesView = [[AEMessagesViewController alloc] init];
        [self presentViewController:messagesView animated:NO completion:nil];
        
    }
    
    else if([[sender currentTitle] isEqualToString:@"Message"])
    {
        AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
        conversationView.senderImage = imageView.image;
        conversationView.dogHandle = _dogHandle;
        conversationView.dogID = _dogID;
        [self presentViewController:conversationView animated:NO completion:nil];
    }
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
    if([newJSON objectForKey:@"profile"])
    {
        profile = [newJSON objectForKey:@"profile"];
        self.location.text = [NSString stringWithFormat:@"%@",[profile valueForKey:@"location"]];
        self.personality.text = [NSString stringWithFormat:@"%@",[profile valueForKey:@"personality_type"]];
        self.gender.text = [NSString stringWithFormat:@"%@",[profile valueForKey:@"gender"]];
        self.age.text = [NSString stringWithFormat:@"%@",[profile valueForKey:@"age"]];
        self.owners_name.text = [NSString stringWithFormat:@"%@",[profile valueForKey:@"humans_name"]];
        self.breed.text = [NSString stringWithFormat:@"%@",[profile valueForKey:@"breed"]];
        self.size.text = [NSString stringWithFormat:@"%@",[profile valueForKey:@"size"]];
        self.spayed.text = [NSString stringWithFormat:@"%@",[profile valueForKey:@"fertility"]];
        
        NSURL *url = [NSURL URLWithString:@"http://vast-inlet-7785.herokuapp.com/testImage.png"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
    }
    else if([newJSON objectForKey:@"profile_photo"]){
        NSLog(@"%@ jownnn",[newJSON objectForKey:@"profile_photo"]);
        [imageView setImageWithURL:[NSURL URLWithString:[newJSON objectForKey:@"profile_photo"]]
                       placeholderImage:[UIImage imageNamed:@"default_marker.png"]];
        
        [self.activity stopAnimating];
    }
    
    
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
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