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
        self.isMine = NO;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _navTitle.title = _dogHandle;
    NSLog(@"nav title duh %@",_dogHandle);
    NSLog(@"dog id %@",_dogID);
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 60;
    [self.activity startAnimating];
    self.activity.hidesWhenStopped = YES;
    NSString *title = [NSString stringWithFormat:@"%@'s Pack",_dogHandle];
    [_packButton setTitle:title forState:UIControlStateNormal];
    ;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self loadUserInfo];
    if(self.isFriend){
        NSLog(@"friend trew");
        [self.actionButton setTitle:@"Message" forState:UIControlStateNormal];
        
    }
    else if(self.isMine){
        NSLog(@"mine trew");
        [self.actionButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
    } 
    else {
        NSLog(@"request trew");
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

        [self dismissViewControllerAnimated:YES completion:nil];
        
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
        NSLog(@"JSON %@",[newJSON objectForKey:@"profile"]);
        
        _profile = [newJSON objectForKey:@"profile"];
        if([NSNull null] != [_profile valueForKey:@"age"]){
            NSLog(@"golden jowns %@",[_profile valueForKey:@"age"]);
            _age.text = [NSString stringWithFormat:@"%@",[_profile valueForKey:@"age"]];
        }
        if([NSNull null] != [_profile valueForKey:@"gender"]){
            _gender.text = [_profile valueForKey:@"gender"];
        }
        if([NSNull null] != [_profile valueForKey:@"size"]){
            _size.text = [_profile valueForKey:@"size"];
            
        }
        if([NSNull null] != [_profile valueForKey:@"fertility"]){
            _spayed.text = [_profile valueForKey:@"fertility"];
            
        }
        if([NSNull null] != [_profile valueForKey:@"personality_type"]){
            _personality.text = [_profile valueForKey:@"personality_type"];
            
        }
        if([NSNull null] != [_profile valueForKey:@"humans_name"]){
            _owners_name.text = [_profile valueForKey:@"humans_name"];
            
        }
        if([NSNull null] != [_profile valueForKey:@"location"]){
            _location.text = [NSString stringWithFormat:@"%@",[_profile valueForKey:@"location"]];
        }
        if([NSNull null] != [_profile valueForKey:@"breed"]){
            _breed.text = [NSString stringWithFormat:@"%@",[_profile valueForKey:@"breed"]];
        }

        
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