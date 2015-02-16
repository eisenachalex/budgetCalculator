//
//  AEProfileViewConxtroller.m
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

    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 60;
    [self.imageView.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
    [self.imageView.layer setBorderWidth: 3.0];
    [self.activity startAnimating];
    self.activity.hidesWhenStopped = YES;
    
    
    ;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadUserInfo];

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

    [self dismissViewControllerAnimated:NO completion:nil];
}



- (IBAction)buddies:(id)sender {
    AEBuddiesViewController *buddiesView = [[AEBuddiesViewController alloc] init];
    buddiesView.foreign_dog_id = _dogID;
    buddiesView.locationController = _locationController;
    [self presentViewController:buddiesView animated:NO completion:nil];
}



-(IBAction)actionButton:(id)sender{

        AEEditProfileViewController *editProfile = [[AEEditProfileViewController alloc] init];
        editProfile.profile = _profile;
        editProfile.dogID = _dogID;
        [self presentViewController:editProfile animated:NO completion:nil];
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
        NSString *returnString = [[NSString alloc] init];
        returnString = [NSString stringWithFormat:@"Hi, my name is %@!", _dogHandle];

        _profile = [newJSON objectForKey:@"profile"];
        if(([NSNull null] != [_profile valueForKey:@"age"]) || ([NSNull null] != [_profile valueForKey:@"gender"]) || ([NSNull null] != [_profile valueForKey:@"breed"])){
            returnString = [NSString stringWithFormat:@"%@. I'm a", returnString];
        }
        
        
        if([NSNull null] != [_profile valueForKey:@"age"]){
            returnString = [NSString stringWithFormat:@"%@ %@ year old",returnString,[_profile valueForKey:@"age"]];
        }
        if([NSNull null] != [_profile valueForKey:@"gender"]){
            returnString = [NSString stringWithFormat:@"%@ %@",returnString, [_profile valueForKey:@"gender"]];
        }
        if([NSNull null] != [_profile valueForKey:@"breed"]){
            NSLog(@"breed is not null");
            returnString = [NSString stringWithFormat:@"%@ %@",returnString, [_profile valueForKey:@"breed"]];
        }
        if([NSNull null] != [_profile valueForKey:@"fertility"]){
            returnString = [NSString stringWithFormat:@"%@.  I'm %@",returnString,[_profile valueForKey:@"fertility"]];
            
        }
        if([NSNull null] != [_profile valueForKey:@"size"]){
            returnString = [NSString stringWithFormat:@"%@ and %@",returnString, [_profile valueForKey:@"size"]];
            
        }
        
        if([NSNull null] != [_profile valueForKey:@"personality_type"]){
            returnString = [NSString stringWithFormat:@"%@. My pup friends say that I'm %@",returnString, [_profile valueForKey:@"personality_type"]];
        }
        if([NSNull null] != [_profile valueForKey:@"humans_name"]){
            returnString = [NSString stringWithFormat:@"%@. My human best friend is %@",returnString, [_profile valueForKey:@"humans_name"]];
            
        }
        if([NSNull null] != [_profile valueForKey:@"location"]){
            
        }
        returnString = [NSString stringWithFormat:@"%@.",returnString];
        _label.text = returnString;

        
    }
    else if([newJSON objectForKey:@"profile_photo"]){
        NSLog(@"%@",[newJSON objectForKey:@"profile_photo"]);
        [self.imageView setImageWithURL:[NSURL URLWithString:[newJSON objectForKey:@"profile_photo"]]
                       placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar.png"]];
        
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