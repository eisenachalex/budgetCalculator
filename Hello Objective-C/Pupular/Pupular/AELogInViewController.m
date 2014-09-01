//
//  AELogInViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//
#define SCROLLVIEW_CONTENT_HEIGHT 460
#define SCROLLVIEW_CONTENT_WIDTH  320
#import "AELogInViewController.h"
#import "AEHomeMapViewController.h"
#import "AEConvoViewController.h"
#import "AEAboutGuestViewController.h"
#import "AESignUpViewController.h"
#import "AESearchViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AEMessagesViewController.h"
#import "AEMenuViewController.h"

#import "AEAppDelegate.h"
@interface AELogInViewController ()

@end

@implementation AELogInViewController
@synthesize scrollView,spinner;
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
    self.loginError.hidden = TRUE;
    self.email.delegate = self;
    self.password.delegate = self;

    // Do any additional setup after loading the view from its nib.
}


-(void)viewWillAppear:(BOOL)animated
{
    scrollView.contentSize = CGSizeMake(320, 500);
    [self loadUserInfo];
    [super viewWillAppear:YES];


}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [scrollView setContentOffset:CGPointMake(0,textField.center.y-140) animated:YES];//you can set your  y cordinate as your req also
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    
    
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)signIn:(id)sender{
    [spinner startAnimating];
    NSString *email = self.email.text;
    NSString *password = self.password.text;
    NSURL *url = [NSURL URLWithString:@"http://vast-inlet-7785.herokuapp.com/login"];
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", nil];
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:0];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", requestBodyData.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"form-data" forHTTPHeaderField:@"Content-Disposition"];
    [request setHTTPBody:requestBodyData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self];
}

-(IBAction)signUp:(id)sender{
    AESignUpViewController *signUpViewController = [[AESignUpViewController alloc] init];
    [self presentViewController:signUpViewController animated:NO completion:nil];
    
    
}

-(IBAction)about:(id)sender{
    AEAboutGuestViewController *aboutViewController = [[AEAboutGuestViewController alloc] init];
    [self presentViewController:aboutViewController animated:NO completion:nil];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [spinner stopAnimating];
    NSLog(@"Succeeded! Received %d bytes of data", [_responseData length]);
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    NSLog(@"new json %@",newJSON);
    NSString *login_response = [newJSON objectForKey:@"login_status"];
    
    if([login_response  isEqual: @"failed"]){
        self.loginError.hidden = FALSE;
        
    }
    else if([login_response  isEqual: @"success"]){
        NSString *email= [newJSON objectForKey:@"email"];
        NSString *dog_id = [newJSON objectForKey:@"dog_id"];
        NSString *dog_handle = [newJSON objectForKey:@"dog_handle"];
        NSString *image_url = [newJSON objectForKey:@"dog_url"];
        NSLog(@"image_url %@",image_url);
        [userInfo setValue:email forKey:@"email"];
        [userInfo setValue:dog_id forKey:@"dog_id"];
        [userInfo setValue:dog_handle forKey:@"dog_handle"];
        [userInfo setValue:image_url forKey:@"image_url"];
        //[userInfo replaceObjectAtIndex:1 withObject:retrievedPhone];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
        AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
        AEHomeMapViewController *mapView = [[AEHomeMapViewController alloc] init];
        mapView.locationController = appDelegate.locationController;
        mapView.view.tag = 23;
        AEMessagesViewController *messageView = [[AEMessagesViewController alloc] init];
        messageView.view.tag = 12;
        messageView.locationController = appDelegate.locationController;

        AESearchViewController *searchView = [[AESearchViewController alloc] init];
        searchView.locationController = appDelegate.locationController;
        AEActiveFriendsViewController *packView = [[AEActiveFriendsViewController alloc] init];
        packView.locationController = appDelegate.locationController;
        AEMenuViewController *moreView = [[AEMenuViewController alloc] init];
        NSLog(@"good here 1");
        
        UIImage *homeImage = [UIImage imageNamed:@"pupular_track_home.png"] ;
        UIImage *packImage = [UIImage imageNamed:@"pupular_pack_default.png"];
        UIImage *searchImage = [UIImage imageNamed:@"pupular_search_default.png"];
        UIImage *messageImage = [UIImage imageNamed:@"pupular_message_default.png"];
        UIImage *moreImage = [UIImage imageNamed:@"pupular_more_default.png"];
        [mapView.tabBarItem setImage:homeImage];
        [searchView.tabBarItem setImage:searchImage];
        [packView.tabBarItem setImage:packImage];
        [moreView.tabBarItem setImage:moreImage];
        [messageView.tabBarItem setImage:messageImage];
        
        
        //    [mapView.tabBarItem setImage:mapImage];
        //    [accountView.tabBarItem setImage:logOutImage];
        //
        //    UINavigationController *mapNavController = [[UINavigationController alloc]
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        tabBarController.tabBar.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.1 alpha:1];
        [tabBarController setViewControllers:@[mapView,packView,searchView,messageView,moreView]];
        AEAppDelegate *delegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.window setRootViewController:tabBarController];[self presentViewController:tabBarController animated:NO completion:nil];

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



@end
