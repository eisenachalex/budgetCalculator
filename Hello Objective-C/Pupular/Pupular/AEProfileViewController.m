//
//  AEProfileViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEMenuViewController.h"
#import "AEProfileViewController.h"
#import "AEMessagesViewController.h"
#import "AEAdditionView.h"
#import "UIImageView+WebCache.h"
#import "AEBuddiesViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AEAboutViewController.h"
#import "AELogInViewController.h"
#import "AEEditProfileViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AEProfileViewController ()

@end

@implementation AEProfileViewController
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
        NSLog(@"is mine is being jowned");
        [self.actionButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
    }
    else {
        [self.actionButton setTitle:@"Request" forState:UIControlStateNormal];
        
    }
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/profile?dog_id=%@",_dogID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    
    NSURLRequest *profile_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/retrieve_profile_photo?dog_id=%@",_dogID]]];
    NSURLConnection *profile = [[NSURLConnection alloc] initWithRequest:profile_request delegate:self];
    _navBar.title = [NSString stringWithFormat:@"%@",_dogHandle];
    NSLog(@"we got that dawg id %@",_dogID);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
    menuView.locationController = _locationController;
    [self presentViewController:menuView animated:YES completion:nil];
}



- (IBAction)buddies:(id)sender {
    AEBuddiesViewController *buddiesView = [[AEBuddiesViewController alloc] init];
    buddiesView.foreign_dog_id = _dogID;
    buddiesView.locationController = _locationController;
    [self presentViewController:buddiesView animated:NO completion:nil];
}



-(IBAction)actionButton:(id)sender{
    NSLog(@"action text %@",[sender currentTitle]);
    if([[sender currentTitle] isEqualToString:@"Edit Profile"])
    {
        AEEditProfileViewController *editProfile = [[AEEditProfileViewController alloc] init];
        editProfile.profile = profile;
        editProfile.image = _profileImage;
        editProfile.dogID = _dogID;
        [self presentViewController:editProfile animated:NO completion:nil];
    }
    else if([[sender currentTitle] isEqualToString:@"Request"])
    {
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/friend_request?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
        NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
        NSLog(@"jowns");
        AEMessagesViewController *messagesView = [[AEMessagesViewController alloc] init];
        [self presentViewController:messagesView animated:NO completion:nil];
        
    }
    
    else if([[sender currentTitle] isEqualToString:@"Message"])
    {
        NSLog(@"up up and away");
        
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
    NSLog(@"JSON %@",[newJSON objectForKey:@"profile"]);
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
        [imageView setImage:image];
        _profileImage = image;
        
    }
    else if([newJSON objectForKey:@"profile_photo"]){
        NSLog(@"%@",[newJSON objectForKey:@"profile_photo"]);
        [self.imageView setImageWithURL:[NSURL URLWithString:[newJSON objectForKey:@"profile_photo"]]
                       placeholderImage:[UIImage imageNamed:@"git_icon_hover.png"]];
        
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
    NSLog(@"here is the user info %@", userInfo);
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    NSLog(@"path %@",paths);
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}






@end