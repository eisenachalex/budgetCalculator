//
//  AESignUpViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//
#import "AESignUpViewController.h"
#import "AEHomeMapViewController.h"

@interface AESignUpViewController ()
@end

@implementation AESignUpViewController
@synthesize imageView,scrollView,contentView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    
    
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        self.imageView.image = [UIImage imageNamed:@"landing_iamge.png"];
        self.password.delegate = self;
        self.passwordConfirm.delegate = self;
        self.handle.delegate = self;
        self.zip.delegate = self;
        self.owner.delegate = self;
        self.gender.delegate = self;
        self.spayed.delegate = self;
        self.personality.delegate = self;
        scrollView.delegate = self;
        base64string = @"jown_IMAGE";
        
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
    
    self.imageView.image = [UIImage imageNamed:@"default_marker.png"];

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
    NSLog(@"Succeeded! Received %d bytes of data", [_responseData length]);
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    NSString *login_response = [newJSON objectForKey:@"login_status"];
    
    //if([login_response  isEqual: @"failed"]){
       // self.loginError.hidden = FALSE;
   
   // }
    if([login_response  isEqual: @"success"]){
        NSString *email= [newJSON objectForKey:@"email"];
        NSString *dog_id = [newJSON objectForKey:@"dog_id"];
        NSString *dog_handle = [newJSON objectForKey:@"dog_handle"];
        [userInfo setValue:email forKey:@"email"];
        [userInfo setValue:dog_id forKey:@"dog_id"];
        [userInfo setValue:dog_handle forKey:@"dog_handle"];
        //[userInfo replaceObjectAtIndex:1 withObject:retrievedPhone];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
        AEHomeMapViewController *mapViewController = [[AEHomeMapViewController alloc] init];
        [self presentViewController:mapViewController animated:YES completion:nil];
        
    }

    

}

-(IBAction)submit:(id)sender {
    NSLog(@"firing");
    NSString *email = self.email.text;
    NSString *password = self.password.text;
    NSString *passwordConfirm = self.passwordConfirm.text;
    NSString *handle = self.handle.text;
    NSString *zip = self.zip.text;
    NSString *owner = self.owner.text;
    NSString *gender = self.gender.text;
    NSString *spayed =  self.spayed.text;
    NSString *personality =  self.personality.text;
    NSURL *url = [NSURL URLWithString:@"http://vast-inlet-7785.herokuapp.com/sign_up"];
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", passwordConfirm, @"passwordConfirm", handle, @"handle",zip,@"zip",owner,@"owner",gender,@"gender",spayed,@"spayed",personality,@"personality",base64string,@"photo",nil];
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
