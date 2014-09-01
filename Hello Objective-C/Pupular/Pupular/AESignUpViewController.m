//
//  AESignUpViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//
#import "AESignUpViewController.h"
#import "AEHomeMapViewController.h"
#import "AESearchViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AEMessagesViewController.h"
#import "AEMenuViewController.h"
#import "AEAppDelegate.h"

@interface AESignUpViewController ()
@end

@implementation AESignUpViewController
@synthesize imageView,scrollView,contentView,spinner;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        base64string = @"none";
        
    }
    return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"%@",NSStringFromCGRect(textField.frame));
    [scrollView setContentOffset:CGPointMake(0,textField.center.y-100)animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 60;
    [self.imageView.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
    [self.imageView.layer setBorderWidth: 3.0];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    _statusLabel.hidden = YES;
    self.pickerArray  = [[NSMutableArray alloc]         initWithObjects:@"Blue",@"Green",@"Orange",@"Purple",@"Red",@"Yellow" , nil];

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        self.password.delegate = self;
        self.passwordConfirm.delegate = self;
        self.handle.delegate = self;
        self.zip.delegate = self;
        scrollView.delegate = self;
        
        }
}// Do any additional setup after loading the view from its nib.


-(void)viewWillAppear:(BOOL)animated{
    // scrollview won't scroll unless content size explicitly set
    //
    
    [scrollView addSubview:contentView];//if the contentView is not already inside your scrollview in your xib/StoryBoard doc
    
    scrollView.contentSize = contentView.frame.size; //set
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendImage:(id)sender {
}

- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)selectPhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];

}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    NSString* imageString = [self encodeToBase64String:chosenImage];
    base64string = imageString;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
    NSLog(@"response received");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
    NSLog(@"data received");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [spinner stopAnimating];
    NSLog(@"Succeeded! Received %d bytes of data", [_responseData length]);
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    NSString *login_response = [newJSON objectForKey:@"login_status"];
    NSLog(@"jsonnnn %@",newJSON);
    //if([login_response  isEqual: @"failed"]){
       // self.loginError.hidden = FALSE;
   
   // }
    if([login_response isEqualToString: @"success"]){
        NSLog(@"cuz we own");
        NSString *email= [newJSON objectForKey:@"email"];
        NSString *dog_id = [newJSON objectForKey:@"dog_id"];
        NSString *dog_handle = [newJSON objectForKey:@"dog_handle"];
        NSString *image_url = [newJSON objectForKey:@"dog_url"];

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

        [tabBarController setViewControllers:@[mapView,packView,searchView,messageView,moreView]];        [self presentViewController:tabBarController animated:NO completion:nil];
        
        
    }
    if([login_response isEqualToString: @"failure"]){
        _statusLabel.textColor = [UIColor redColor];
        NSString *email= [newJSON objectForKey:@"email"];
        NSString *dog_id = [newJSON objectForKey:@"dog_id"];
        NSString *dog_handle = [newJSON objectForKey:@"dog_handle"];
        _statusLabel.text = [newJSON objectForKey:@"reason"];
        _statusLabel.hidden = NO;
        [_submitButton setTitle:@"Complete" forState:UIControlStateNormal];
    }

    

}

-(IBAction)submit:(id)sender {
    NSLog(@"yoyoyo its thats base %@",base64string);
    if([base64string isEqualToString:@"none"]){
        NSLog(@"trigger central");
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"You Must Choose A Photo!"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    else{
    _statusLabel.textColor = [UIColor blackColor];
    _statusLabel.text = @"Processing...";
    _statusLabel.hidden = NO;
    [_submitButton setTitle:@"" forState:UIControlStateNormal];
    [spinner startAnimating];
    NSString *email = self.email.text;
    NSString *password = self.password.text;
    NSString *passwordConfirm = self.passwordConfirm.text;
    NSString *handle = self.handle.text;
    NSString *zip = self.zip.text;
    NSURL *url = [NSURL URLWithString:@"http://vast-inlet-7785.herokuapp.com/sign_up"];
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", passwordConfirm, @"passwordConfirm", handle, @"handle",zip,@"zip",base64string,@"photo",nil];
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


//data picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(void)dismissKeyboard {
    [_zip resignFirstResponder];
    [_passwordConfirm resignFirstResponder];
    [_password resignFirstResponder];
    [_email resignFirstResponder];
    [_handle resignFirstResponder];
    
}


// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return 6;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [self.pickerArray objectAtIndex:row];

}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{

  
}



@end
