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
#import "AEAppDelegate.h"

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
    _navTitle.title = _dogHandle;
    NSLog(@"nav title duh %@",_dogHandle);
    NSLog(@"dog id %@",_dogID);
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/is_friend?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
//    NSLog(@"request being made with dogid %@ & friend id %@",[userInfo valueForKey:@"dog_id"],_dogID]);
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    [self loadUserInfo];
    if(self.isFriend){
        NSLog(@"friend trew");
        [self.actionButton setTitle:@"Message" forState:UIControlStateNormal];
        self.actionButton.titleLabel.hidden = YES;

    }
    else if(self.isMine){
        NSLog(@"mine trew");
        [self.actionButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
    }
    else {
        NSLog(@"request trew");


    }
    self.actionButton.titleLabel.hidden = YES;
    NSURLRequest *db_request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/profile?dog_id=%@",_dogID]]];
    NSURLConnection *db_conn2 = [[NSURLConnection alloc] initWithRequest:db_request2 delegate:self];
    
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
    buddiesView.dogHandle = _dogHandle;
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
        NSLog(@"TREWerr");
        NSLog(@"DOG ID %@",[userInfo valueForKey:@"dog_id"]);
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/friend_request?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
        AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.tabBarController setSelectedIndex:3];

        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    else if([[sender currentTitle] isEqualToString:@"Message"])
    {
        AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
        UITableViewCell *tableViewCell = [[UITableViewCell alloc] init];
        tableViewCell.imageView.image= imageView.image;
        conversationView.senderImage = tableViewCell.imageView.image;
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
//        Hi, my name is BobbieMcgee88! I'm a 4  year
//        old female Mutt. I'm spayed and 25-50lbs. My pup
//        friends say that I'm playful and a little alpha. My
//        human best friend is Harry Boileau.

        NSLog(@"JSON %@",[newJSON objectForKey:@"profile"]);
        NSString *returnString = [[NSString alloc] init];
        returnString = [NSString stringWithFormat:@"Hi, my name is %@!", _dogHandle];
        _profile = [newJSON objectForKey:@"profile"];
        
        if(([NSNull null] != [_profile valueForKey:@"age"]) || ([NSNull null] != [_profile valueForKey:@"gender"]) || ([NSNull null] != [_profile valueForKey:@"breed"])){
            returnString = [NSString stringWithFormat:@"%@ I'm a", returnString];
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
        NSLog(@"%@ jownnn",[newJSON objectForKey:@"profile_photo"]);
        [imageView setImageWithURL:[NSURL URLWithString:[newJSON objectForKey:@"profile_photo"]]
                       placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar.png"]];
        
        [self.activity stopAnimating];
    }
    else if([newJSON objectForKey:@"is_friend"]){
        NSLog(@"NEW JSON FOR HARRY %@",[newJSON objectForKey:@"is_friend"]);
        NSString *stringValue = [NSString stringWithFormat:@"%@",[newJSON valueForKey:@"is_friend"]];
        NSLog(@"HERE BE DAT STRING %@",stringValue);
        if([stringValue isEqualToString:@"1"]){
            [self.actionButton setTitle:@"Message" forState:UIControlStateNormal];
            [self.actionButton setBackgroundImage:[UIImage imageNamed:@"pupular_message_button.png"] forState:UIControlStateNormal];
        }
        else{
            [self.actionButton setTitle:@"Request" forState:UIControlStateNormal];
            [self.actionButton setBackgroundImage:[UIImage imageNamed:@"pupular_add_button.png"] forState:UIControlStateNormal];
        }
        self.actionButton.titleLabel.hidden = YES;


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