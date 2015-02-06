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
    [self loadUserInfo];

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

-(IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
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
    //if([login_response  isEqual: @"failed"]){
       // self.loginError.hidden = FALSE;
   
   // }
    if([login_response isEqualToString: @"success"]){
        NSString *email= [newJSON objectForKey:@"email"];
        NSString *dog_id = [newJSON objectForKey:@"dog_id"];
        NSString *dog_handle = [newJSON objectForKey:@"dog_handle"];
        NSString *image_url = [newJSON objectForKey:@"dog_url"];
        NSMutableArray *read_messages = [[NSMutableArray alloc] init];
        [userInfo setValue:email forKey:@"email"];
        [userInfo setValue:dog_id forKey:@"dog_id"];
        [userInfo setValue:@"false" forKey:@"is_active"];
        [userInfo setValue:dog_handle forKey:@"dog_handle"];
        [userInfo setValue:image_url forKey:@"image_url"];
        [userInfo setValue:read_messages forKey:@"read_messages"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
        AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate startTimer];
        [appDelegate getAllDogs];
        [appDelegate.tabBarController setSelectedIndex:0];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.delegate dismissMe];
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
    if([base64string isEqualToString:@"none"]){
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
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
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





-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [self.pickerArray objectAtIndex:row];

}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{

  
}



@end
