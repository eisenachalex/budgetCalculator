//
//  AELoginViewController.m
//  Sketch
//
//  Created by Alex Eisenach on 5/1/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#define SCROLLVIEW_CONTENT_HEIGHT 460
#define SCROLLVIEW_CONTENT_WIDTH  320
#import "AELoginViewController.h"
#import "AEHomeViewController.h"
#import "AEMapViewController.h"
#import "AEAccountSettingsViewController.h"
@interface AELoginViewController ()

@end

@implementation AELoginViewController
@synthesize scrollView;
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
    self.registerError.hidden = TRUE;
    [self loadUserInfo];
    self.mobilePhone.delegate = self;
    self.username.delegate = self;
    self.createUserName.delegate = self;
    self.createUserPassword.delegate = self;
    self.createUserPasswordConfirm.delegate = self;
    self.password.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    scrollView.contentSize = CGSizeMake(320, 500);
    
    [super viewWillAppear:YES];
    [self loadUserInfo];
    self.loginError.hidden = TRUE;
    self.registerError.hidden = TRUE;
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


- (IBAction)logIn:(id)sender{
    NSString *username = self.username.text;
    NSString *password = self.password.text;
    validUserName = username;
    NSURL *url = [NSURL URLWithString:@"https://sheltered-harbor-2567.herokuapp.com/login"];
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", nil];
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



- (IBAction)signUp:(id)sender{
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    [self.view endEditing:YES];
    NSString *username = self.createUserName.text;
    NSString *password = self.createUserPassword.text;
    NSString *mobile = self.mobilePhone.text;
    NSLog(@"time to go mobile %i",[mobile intValue]);
    validPhone = mobile;
    validUserName = username;
    NSString *passwordConfirm = self.createUserPasswordConfirm.text;
    NSURL *url = [NSURL URLWithString:@"https://sheltered-harbor-2567.herokuapp.com/create_new_user"];
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", mobile, @"mobile", nil];
    
    if ([username isEqual:@""]){
        self.registerError.text = @"Username required";
        self.registerError.hidden = FALSE;
    }
    else if ([password isEqual:@""] || [passwordConfirm isEqual:@""]) {
        self.registerError.text = @"Password required";
        self.registerError.hidden = FALSE;
    }
    
    
    else if (mobile.length < 10 || mobile.length > 10 || ([mobile intValue] == 0)) {
        self.registerError.text = @"Invalid mobile number";
        self.registerError.hidden = FALSE;
    }
    
    else if (![passwordConfirm isEqual:password]){
        self.registerError.text = @"Passwords don't match!";
        self.registerError.hidden = FALSE;
    }
    else{
        self.registerError.hidden = TRUE;
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

}

-(void)resetPlaceholders {
    [self.createUserPasswordConfirm setText:@"Confirm Password"];
    [self.mobilePhone setText:@"Mobile Phone"];
    [self.createUserName setText:@"Username"];
    [self.createUserPassword setText:@"Password"];
}

-(void)presentMainView {
    AEMapViewController *mapView = [[AEMapViewController alloc] init];
    AEAccountSettingsViewController *accountView = [[AEAccountSettingsViewController alloc] init];
    AEHomeViewController *mainView = [[AEHomeViewController alloc] init];
    UIImage *homeImage = [[UIImage imageNamed:@"track_star_signal_OFF.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImage *mapImage = [[UIImage imageNamed:@"track_star_map_icon2.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImage *logOutImage = [[UIImage imageNamed:@"track_star_logout.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    [mainView.tabBarItem setImage:homeImage];
    [mapView.tabBarItem setImage:mapImage];
    [accountView.tabBarItem setImage:logOutImage];

    UINavigationController *mapNavController = [[UINavigationController alloc] initWithRootViewController:mapView];
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:@[mainView,mapNavController,accountView]];
    [tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"track_star_background.png"]];
    [self presentViewController:tabBarController animated:YES completion:nil];
}




- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
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
        NSString *retrievedPhone = [newJSON objectForKey:@"phone_number"];
        NSLog(@"RETRIEVED %@",retrievedPhone);
        [userInfo replaceObjectAtIndex:0 withObject:validUserName];
        [userInfo replaceObjectAtIndex:1 withObject:retrievedPhone];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
        [self presentMainView];

    }
    else if([login_response  isEqual: @"user already exists"]){
        self.registerError.text = @"Username taken!";
        self.registerError.hidden = FALSE;

    }
    else if ([login_response isEqual: @"mobile number already exists"]){
        self.registerError.text = @"Mobile already registered";
        self.registerError.hidden = FALSE;
    }
    else if ([login_response isEqual: @"new user created"]){
        [userInfo replaceObjectAtIndex:0 withObject:validUserName];
        [userInfo replaceObjectAtIndex:1 withObject:validPhone];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
        [self presentMainView];

    }
}



- (void)loadUserInfo {
    NSString *filePath = [self pathForUserInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userInfo = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        userInfo = [NSMutableArray arrayWithObjects:@"empty", @"blank", nil];
        
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
