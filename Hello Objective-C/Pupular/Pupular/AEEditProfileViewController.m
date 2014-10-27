//
//  AEEditProfileViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/5/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEEditProfileViewController.h"
#import "UIImageView+WebCache.h"
#import "AEAppDelegate.h"

@interface AEEditProfileViewController ()

@end

@implementation AEEditProfileViewController
@synthesize scrollView,contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization;

    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [scrollView addSubview:contentView];
    scrollView.contentSize = contentView.frame.size;
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _allDogs = appDelegate.allDogs;
    NSString *dogID = _dogID;
    _dog = [_allDogs objectForKey:[NSString stringWithFormat:@"%@",dogID]];
    _profile = [_dog objectForKey:@"profile"];
    if(![[_profile objectForKey:@"gender"] isEqual:[NSNull null]]){
        _gender.text = [_profile valueForKey:@"gender"];
    }
    if(![[_profile objectForKey:@"age"] isEqual:[NSNull null]]){
        _age.text = [NSString stringWithFormat:@"%@",[_profile valueForKey:@"age"]];
    }
    
    if(![[_profile objectForKey:@"breed"] isEqual:[NSNull null]]){
        _breed.text = [_profile valueForKey:@"breed"];
    }
    if(![[_profile objectForKey:@"size"] isEqual:[NSNull null]]){
        _size.text = [_profile valueForKey:@"size"];
        
    }
    if(![[_profile objectForKey:@"fertility"] isEqual:[NSNull null]]){
        _spayed.text = [_profile valueForKey:@"fertility"];
        
    }
    if(![[_profile objectForKey:@"personality_type"] isEqual:[NSNull null]]){
        _personality.text = [_profile valueForKey:@"personality_type"];
        
    }
    if(![[_profile objectForKey:@"humans_name"] isEqual:[NSNull null]]){
        _owner.text = [_profile valueForKey:@"humans_name"];
    }
    
    if(![[_profile objectForKey:@"location"] isEqual:[NSNull null]]){
        _zip.text = [NSString stringWithFormat:@"%@",[_profile valueForKey:@"location"]];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadUserInfo];
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 60;
    [self.imageView.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
    [self.imageView.layer setBorderWidth: 3.0];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    self.zip.delegate = self;
    self.breed.delegate = self;
    self.owner.delegate = self;
    self.age.delegate = self;
    self.personality.delegate = self;
    self.size.delegate = self;
    [self.view addGestureRecognizer:tap];
            _fixedOptions = [[NSMutableArray alloc] initWithObjects:@"Nice",@"Aggressive",@"fun",@"caring",@"calm",nil];
    scrollView.delegate = self;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        base64string = @"none";
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    _imageView.image = _image;

}

-(void)dismissKeyboard {
    [_targetField resignFirstResponder];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return [_fixedOptions count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [_fixedOptions objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    _targetField.text = [_fixedOptions objectAtIndex:row];
    if(![_targetField.text isEqualToString:@""]){
        [_targetField resignFirstResponder];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{

    UIPickerView *picker = [[UIPickerView alloc]
                            initWithFrame:CGRectMake(0, 244, 320, 270)];
    _targetField = textField;
    picker.backgroundColor = [UIColor whiteColor];
    picker.delegate = self;
    picker.dataSource = self;
    if(textField.tag == 1){
    }
    else if(textField.tag == 2){
        _fixedOptions = [[NSMutableArray alloc] initWithObjects:@"",@"spayed", @"neutered", @"unaltered", nil];
        [picker reloadAllComponents];
        textField.inputView = picker;
        
    }
    else if(textField.tag == 3){
        _fixedOptions = [[NSMutableArray alloc] initWithObjects:@"", @"male", @"female", nil];
        [picker reloadAllComponents];
        textField.inputView = picker;

    }
    else if(textField.tag == 4){
        _fixedOptions = [[NSMutableArray alloc] initWithObjects:@"< 25 lbs", @"25-50 lbs", @"over 50 lbs", nil];
        [picker reloadAllComponents];
        textField.inputView = picker;
        
    }
    else if(textField.tag == 5){
        _fixedOptions = [[NSMutableArray alloc] initWithObjects:@"aggressive", @"playful and a little alpha", @"playful and a little shy",@"passive", nil];
        [picker reloadAllComponents];
        textField.inputView = picker;
        
    }
    [scrollView setContentOffset:CGPointMake(0,textField.center.y-100)animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(IBAction)submit:(id)sender {
    [_spinner startAnimating];
    NSString *breed = self.breed.text;
    NSString *age = self.age.text;
    NSString *zip = self.zip.text;
    NSString *owner = self.owner.text;
    NSString *gender = self.gender.text;
    NSString *spayed =  self.spayed.text;
    NSString *size = self.size.text;
    NSString *personality =  self.personality.text;
    NSURL *url = [NSURL URLWithString:@"http://dry-shelf-9195.herokuapp.com/edit_profile"];
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:owner,@"owner",zip,@"zip",size,@"size",age,@"age",breed,@"breed",gender,@"gender",spayed,@"spayed",personality,@"personality",base64string ?: @"none",@"photo",_dogID,@"dog_id",nil];
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
    [_profile setObject:breed forKey:@"breed"];
    int intAge = [age intValue];
    NSNumber *revisedAge = [NSNumber numberWithInt:intAge];
    [_profile setObject:revisedAge forKey:@"age"];
    [_profile setObject:zip forKey:@"location"];
    [_profile setObject:owner forKey:@"humans_name"];
    [_profile setObject:gender forKey:@"gender"];
    [_profile setObject:spayed forKey:@"fertility"];
    [_profile setObject:size forKey:@"size"];
    [_profile setObject:personality forKey:@"personality_type"];
    [_dog setObject:_profile forKey:@"profile"];
    NSString *dogID = _dogID;
    [_allDogs setObject:_dog forKey:dogID];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allDogs = _allDogs;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];

   if([newJSON objectForKey:@"dog_url"]){
       NSString *imageURL = [newJSON objectForKey:@"dog_url"];
       NSString *thumbURL = [newJSON objectForKey:@"dog_thumb_url"];
       NSMutableArray *photoList = [_dog objectForKey:@"photo_list"];
       if(![imageURL isEqualToString:@"none"]){
           [photoList replaceObjectAtIndex:0 withObject:imageURL];
           [photoList replaceObjectAtIndex:1 withObject:thumbURL];
           [_dog setObject:photoList forKey:@"photo_list"];
           [_allDogs setObject:_dog forKey:_dogID];
           AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
           appDelegate.allDogs = _allDogs;
       }
       [userInfo setValue:thumbURL forKey:@"image_url"];
       [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
       [self dismissViewControllerAnimated:NO completion:nil];
   }
   else{
       [_spinner stopAnimating];
   }
}

- (void)loadUserInfo {
    NSString *filePath = [self pathForUserInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        
    }
    else {
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
