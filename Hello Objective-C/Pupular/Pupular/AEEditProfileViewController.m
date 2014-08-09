//
//  AEEditProfileViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/5/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEEditProfileViewController.h"


@interface AEEditProfileViewController ()

@end

@implementation AEEditProfileViewController

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
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        base64string = @"none";
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    _zip.text = [NSString stringWithFormat:@"%@",[_profile valueForKey:@"location"] ?: @""];
    _owner.text = [_profile valueForKey:@"humans_name"] ?: @"" ;
    _breed.text = [_profile valueForKey:@"breed"] ?: @"";
    _age.text = [NSString stringWithFormat:@"%@",[_profile valueForKey:@"age"] ?: @""];
    _gender.text = [_profile valueForKey:@"gender"] ?: @"";
    _size.text = [_profile valueForKey:@"size"] ?: @"";
    _spayed.text = [_profile valueForKey:@"fertility"] ?: @"";
    _personality.text = [_profile valueForKey:@"personality_type"];
    _imageView.image = _image;}

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

    NSString *zip = self.zip.text;
    NSString *breed = self.breed.text;
    NSString *age = self.age.text;
    NSString *location = self.zip.text;
    NSString *owner = self.owner.text;
    NSString *gender = self.gender.text;
    NSString *spayed =  self.spayed.text;
    NSString *size = self.size.text;
    NSString *personality =  self.personality.text;
    NSString *this_id = _dogID;
    NSLog(@"HERE BE THE ID U HERE %@",_dogID);
    NSURL *url = [NSURL URLWithString:@"http://vast-inlet-7785.herokuapp.com/edit_profile"];
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:zip,@"zip",owner,@"owner",size,@"size",age,@"age",breed,@"breed",gender,@"gender",spayed,@"spayed",personality,@"personality",base64string ?: @"none",@"photo",_dogID,@"dog_id",nil];
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


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [_spinner stopAnimating];
    [self dismissViewControllerAnimated:NO completion:nil];

}

@end
