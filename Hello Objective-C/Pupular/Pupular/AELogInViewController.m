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
#import "AEAppDelegate.h"
#import "AEAboutViewController.h"
#import "AESignUpViewController.h"
#import "AESearchViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AEMessagesViewController.h"
#import "AEMenuViewController.h"
#import "AETabBarViewController.h"

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


-(void)dismissMe{
    [self.tabBarController.viewControllers objectAtIndex:1];
    [self.delegate viewWillAppear:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    NSURL *url = [NSURL URLWithString:@"http://dry-shelf-9195.herokuapp.com/login"];
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
    signUpViewController.delegate = self;
    [self presentViewController:signUpViewController animated:NO completion:nil];
    
    
}

-(IBAction)about:(id)sender{
    AEAboutViewController *aboutViewController = [[AEAboutViewController alloc] init];
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
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    NSString *login_response = [newJSON objectForKey:@"login_status"];
    
    if([login_response  isEqual: @"failed"]){
        self.loginError.hidden = FALSE;
        
    }
    else if([login_response  isEqual: @"success"]){
        NSString *email= [newJSON objectForKey:@"email"];
        NSString *dog_id = [newJSON objectForKey:@"dog_id"];
        NSString *dog_handle = [newJSON objectForKey:@"dog_handle"];
        NSString *image_url = [newJSON objectForKey:@"dog_url"];
        [userInfo setValue:email forKey:@"email"];
        [userInfo setValue:dog_id forKey:@"dog_id"];
        [userInfo setValue:dog_handle forKey:@"dog_handle"];
        [userInfo setValue:image_url forKey:@"image_url"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
        AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate startTimer];
        [appDelegate getAllDogs];
        [appDelegate.tabBarController setSelectedIndex:0];
        [self.delegate viewWillAppear:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
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
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}

@end
