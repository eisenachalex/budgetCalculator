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
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadUserInfo];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _allDogs = appDelegate.allDogs;
    NSString *dogID = _dogID;
    _dog = [_allDogs objectForKey:[NSString stringWithFormat:@"%@",dogID]];
    _navTitle.title = [_dog valueForKey:@"handle"];
    [self buildProfile];
    [self isFriend:appDelegate.friendList];
    if(self.isFriend){
        [self.actionButton setBackgroundImage:[UIImage imageNamed:@"pupular_message_button.png"] forState:normal];
        _buttonStatus = @"Message";
    }

    else {
        [self.actionButton setBackgroundImage:[UIImage imageNamed:@"pupular_add_button.png"] forState:normal];
        _buttonStatus = @"Request";
    }
    
}

-(void)buildProfile{
    NSString *returnString = [[NSString alloc] init];
    returnString = [NSString stringWithFormat:@"Hi, my name is %@!", [_dog valueForKey:@"handle"]];
    NSDictionary *dog = [_dog valueForKey:@"profile"];
    if((([NSNull null] != [dog objectForKey:@"age"]) && (![[dog objectForKey:@"age"] isEqualToNumber:[NSNumber numberWithInt:0]])) || (([NSNull null] != [dog objectForKey:@"gender"]) && (![[dog valueForKey:@"gender"] isEqualToString:@""]) && (![[dog valueForKey:@"gender"] isEqualToString:@"(null)"])) || (([NSNull null] != [dog objectForKey:@"breed"]) && (![[dog valueForKey:@"breed"] isEqualToString:@"(null)"]) && (![[dog valueForKey:@"breed"] isEqualToString:@""]))){
        returnString = [NSString stringWithFormat:@"%@ I'm a", returnString];
    }
    
    
    if(([NSNull null] != [dog objectForKey:@"age"]) && (![[dog objectForKey:@"age"] isEqualToNumber:[NSNumber numberWithInt:0]]) ){
        returnString = [NSString stringWithFormat:@"%@ %@ year old",returnString,[dog valueForKey:@"age"]];
      
    }
    if([NSNull null] != [dog objectForKey:@"gender"]){
        if(![[dog valueForKey:@"gender"] isEqualToString:@""]){

        returnString = [NSString stringWithFormat:@"%@ %@",returnString, [dog valueForKey:@"gender"]];
        }
    }
    if([NSNull null] != [dog objectForKey:@"breed"]){
        if(![[dog valueForKey:@"breed"] isEqualToString:@"(null)"]){
        returnString = [NSString stringWithFormat:@"%@ %@",returnString, [dog valueForKey:@"breed"]];
        }
    }
    if(![returnString hasSuffix:@"!"]){
        returnString = [NSString stringWithFormat:@"%@.",returnString];
    }
    if([NSNull null] != [dog objectForKey:@"fertility"]){
        if(![[dog valueForKey:@"fertility"] isEqualToString:@""]){
        returnString = [NSString stringWithFormat:@"%@  I'm %@",returnString,[dog valueForKey:@"fertility"]];
        }
    }
    if([NSNull null] != [dog objectForKey:@"size"]){
        if(![[dog valueForKey:@"size"] isEqualToString:@""]){

        returnString = [NSString stringWithFormat:@"%@ and %@",returnString, [dog valueForKey:@"size"]];
        }
    }
    
    if([NSNull null] != [dog objectForKey:@"personality_type"]){
        if(![[dog valueForKey:@"personality_type"] isEqualToString:@""]){
            if([returnString hasSuffix:@"."]){
        returnString = [NSString stringWithFormat:@"%@ My pup friends say that I'm %@",returnString, [dog valueForKey:@"personality_type"]];           }
            else{
        returnString = [NSString stringWithFormat:@"%@. My pup friends say that I'm %@",returnString, [dog valueForKey:@"personality_type"]];
        }
        }
        
    }
    
    
    if([NSNull null] != [dog objectForKey:@"humans_name"]){
        if(![[dog valueForKey:@"humans_name"] isEqualToString:@""]){
            
            if([returnString hasSuffix:@"."]){
       returnString = [NSString stringWithFormat:@"%@ My human best friend is %@",returnString, [dog objectForKey:@"humans_name"]];            }
            else{
       returnString = [NSString stringWithFormat:@"%@. My human best friend is %@",returnString, [dog objectForKey:@"humans_name"]];            }
 
        }
    }
    if([NSNull null] != [dog objectForKey:@"location"]){
        
    }
    NSString *imageURL = [_dog valueForKey:@"photo_list"][0];
    [self.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageURL]]
                   placeholderImage:[UIImage imageNamed:@"pupulardog_avatar_thumb.png"]];
    if([returnString hasSuffix:@"."] || [returnString hasSuffix:@"!"]){
        returnString = [NSString stringWithFormat:@"%@",returnString];
    }
    else{
        returnString = [NSString stringWithFormat:@"%@.",returnString];
    }
    _label.text = returnString;
}

-(void)isFriend:(NSArray *)friendList{
    for (NSString *string in friendList)
    {
        NSString *dogID = _dogID;
        if([string intValue] == [dogID intValue]){
            self.isFriend = YES;
    }
    }
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
    buddiesView.locationController = _locationController;
    buddiesView.dogID = [_dog valueForKey:@"id"];
    [self presentViewController:buddiesView animated:NO completion:nil];
}





-(IBAction)cancel:(id)sender{
    
}



-(IBAction)actionButton:(id)sender{
    if([[sender currentTitle] isEqualToString:@"Edit Profile"])
    {
    }
    else if([_buttonStatus isEqualToString:@"Request"])
    {
        NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/friend_request?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
        AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.tabBarController setSelectedIndex:3];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    else if([_buttonStatus isEqualToString:@"Message"])
    {
        AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
        UITableViewCell *tableViewCell = [[UITableViewCell alloc] init];
        tableViewCell.imageView.image= imageView.image;
        conversationView.senderImage = self.convoImage;
        conversationView.delegate = [self.tabBarController.viewControllers objectAtIndex:3];
        conversationView.dogHandle = [_dog valueForKey:@"handle"];
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