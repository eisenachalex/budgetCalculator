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
#import "AEAppDelegate.h"

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
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _allDogs = appDelegate.allDogs;
    NSString *dogID = _dogID;
    _dog = [_allDogs objectForKey:[NSString stringWithFormat:@"%@",dogID]];
    [self buildProfile];
    _navBar.title = [_dog valueForKey:@"handle"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)menu:(id)sender{

    [self dismissViewControllerAnimated:NO completion:nil];
}


-(IBAction)actionButton:(id)sender{

        AEEditProfileViewController *editProfile = [[AEEditProfileViewController alloc] init];
        editProfile.dogID = _dogID;
        editProfile.image = imageView.image;
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

-(void)buildProfile{
    NSString *returnString = [[NSString alloc] init];
    returnString = [NSString stringWithFormat:@"Hi, my name is %@!", [_dog valueForKey:@"handle"]];
    NSDictionary *dog = [_dog valueForKey:@"profile"];
    if(((![[dog objectForKey:@"age"] isEqual:[NSNull null]]) && (![[dog objectForKey:@"age"] isEqualToNumber:[NSNumber numberWithInt:0]])) || (([NSNull null] != [dog objectForKey:@"gender"]) && (![[dog valueForKey:@"gender"] isEqualToString:@""]) && (![[dog valueForKey:@"gender"] isEqualToString:@"(null)"])) || (([NSNull null] != [dog objectForKey:@"breed"]) && (![[dog valueForKey:@"breed"] isEqualToString:@"(null)"]) && (![[dog valueForKey:@"breed"] isEqualToString:@""]))){
        returnString = [NSString stringWithFormat:@"%@ I'm a", returnString];
    }
    
    
    if(([NSNull null] != [dog objectForKey:@"age"]) && (![[dog objectForKey:@"age"] isEqualToNumber:[NSNumber numberWithInt:0]]) ){
        returnString = [NSString stringWithFormat:@"%@ %@ year old",returnString,[dog valueForKey:@"age"]];
        
    }
    if(![[dog objectForKey:@"gender"] isEqual:[NSNull null]]){
        if(![[dog valueForKey:@"gender"] isEqualToString:@""]){
            returnString = [NSString stringWithFormat:@"%@ %@",returnString, [dog valueForKey:@"gender"]];
        }
    }
    if(![[dog objectForKey:@"breed"] isEqual:[NSNull null]]){
        if(![[dog valueForKey:@"breed"] isEqualToString:@""]){
            returnString = [NSString stringWithFormat:@"%@ %@",returnString, [dog valueForKey:@"breed"]];
        }
    }
    if(![returnString hasSuffix:@"!"]){
        returnString = [NSString stringWithFormat:@"%@.",returnString];
    }
    if(![[dog objectForKey:@"fertility"] isEqual:[NSNull null]]){
        if(![[dog valueForKey:@"fertility"] isEqualToString:@""]){
            returnString = [NSString stringWithFormat:@"%@  I'm %@",returnString,[dog valueForKey:@"fertility"]];
        }
    }
    if(![[dog objectForKey:@"size"] isEqual:[NSNull null]]){
        if(![[dog valueForKey:@"size"] isEqualToString:@""]){
            
            returnString = [NSString stringWithFormat:@"%@ and %@",returnString, [dog valueForKey:@"size"]];
        }
    }
    
    if(![[dog objectForKey:@"personality_type"] isEqual:[NSNull null]]){
        if(![[dog valueForKey:@"personality_type"] isEqualToString:@""]){
            if([returnString hasSuffix:@"."]){
                returnString = [NSString stringWithFormat:@"%@ My pup friends say that I'm %@",returnString, [dog valueForKey:@"personality_type"]];           }
            else{
                returnString = [NSString stringWithFormat:@"%@. My pup friends say that I'm %@",returnString, [dog valueForKey:@"personality_type"]];
            }
        }
        
    }
    
    
    if(![[dog objectForKey:@"humans_name"] isEqual:[NSNull null]]){
        if(![[dog valueForKey:@"humans_name"] isEqualToString:@""]){
            
            if([returnString hasSuffix:@"."]){
                returnString = [NSString stringWithFormat:@"%@ My human best friend is %@",returnString, [dog objectForKey:@"humans_name"]];            }
            else{
                returnString = [NSString stringWithFormat:@"%@. My human best friend is %@",returnString, [dog objectForKey:@"humans_name"]];            }
            
        }
    }
    

    NSString *imageURL = [_dog valueForKey:@"photo_list"][0];
    [self.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageURL]]
                   placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar.png"]];
    if([returnString hasSuffix:@"."] || [returnString hasSuffix:@"!"]){
        returnString = [NSString stringWithFormat:@"%@",returnString];
    }
    else{
        returnString = [NSString stringWithFormat:@"%@.",returnString];
    }
    _label.text = returnString;
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