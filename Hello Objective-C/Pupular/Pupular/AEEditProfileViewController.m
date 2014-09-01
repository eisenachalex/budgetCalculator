//
//  AEEditProfileViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/5/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEEditProfileViewController.h"
#import "UIImageView+WebCache.h"

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
    [scrollView addSubview:contentView];//if the contentView is not already inside your scrollview in your xib/StoryBoard doc
    
    scrollView.contentSize = contentView.frame.size;
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
    NSURLRequest *profile_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/retrieve_profile_photo?dog_id=%@",_dogID]]];
    NSURLConnection *profile = [[NSURLConnection alloc] initWithRequest:profile_request delegate:self];
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



    if([NSNull null] != [_profile valueForKey:@"age"]){
        _age.text = [NSString stringWithFormat:@"%@",[_profile valueForKey:@"age"]];
    }
    if([NSNull null] != [_profile valueForKey:@"gender"]){
        _gender.text = [_profile valueForKey:@"gender"];
    }
    if([NSNull null] != [_profile valueForKey:@"size"]){
        _size.text = [_profile valueForKey:@"size"];
        
    }
    if([NSNull null] != [_profile valueForKey:@"fertility"]){
        _spayed.text = [_profile valueForKey:@"fertility"];
        
    }
    if([NSNull null] != [_profile valueForKey:@"personality_type"]){
        _personality.text = [_profile valueForKey:@"personality_type"];
        
    }
    if([NSNull null] != [_profile valueForKey:@"humans_name"]){
        _owner.text = [_profile valueForKey:@"humans_name"];
        
    }
    if([NSNull null] != [_profile valueForKey:@"location"]){
        _zip.text = [NSString stringWithFormat:@"%@",[_profile valueForKey:@"location"]];
    }
    if([NSNull null] != [_profile valueForKey:@"breed"]){
        _breed.text = [NSString stringWithFormat:@"%@",[_profile valueForKey:@"breed"]];
    }


    _imageView.image = _image;
}


-(void)dismissKeyboard {
    NSLog(@"jowns");
    [_targetField resignFirstResponder];

}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
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
    NSLog(@"ping pong");
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
        NSLog(@"okay");
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
    // Dispose of any resources that can be recreated.
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
    NSString *location = self.zip.text;
    NSString *owner = self.owner.text;
    NSString *gender = self.gender.text;
    NSString *spayed =  self.spayed.text;
    NSString *size = self.size.text;
    NSString *personality =  self.personality.text;
    NSString *this_id = _dogID;
    NSLog(@"HERE BE THE ID U HERE %@",breed);
    NSURL *url = [NSURL URLWithString:@"http://vast-inlet-7785.herokuapp.com/edit_profile"];
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
   if([newJSON objectForKey:@"profile_photo"]){
        [self.imageView setImageWithURL:[NSURL URLWithString:[newJSON objectForKey:@"profile_photo"]]
                       placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar.png"]];
        
    }
   else{
       [_spinner stopAnimating];
       [self dismissViewControllerAnimated:NO completion:nil];
   }

    

}

@end
