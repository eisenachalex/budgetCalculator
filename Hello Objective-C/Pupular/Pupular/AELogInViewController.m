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
#import "AEAboutViewController.h"
#import "AESignUpViewController.h"
@interface AELogInViewController ()

@end

@implementation AELogInViewController
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
    NSString *email = self.email.text;
    NSString *password = self.password.text;
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/login"];
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
    [self presentViewController:signUpViewController animated:YES completion:nil];
    
    
}

-(IBAction)about:(id)sender{
    AEAboutViewController *aboutViewController = [[AEAboutViewController alloc] init];
    [self presentViewController:aboutViewController animated:YES completion:nil];
    
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
        NSString *email= [newJSON objectForKey:@"email"];
        [userInfo setValue:email forKey:@"email"];
        //[userInfo replaceObjectAtIndex:1 withObject:retrievedPhone];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
        AEHomeMapViewController *mapViewController = [[AEHomeMapViewController alloc] init];
        [self presentViewController:mapViewController animated:YES completion:nil];
        
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
