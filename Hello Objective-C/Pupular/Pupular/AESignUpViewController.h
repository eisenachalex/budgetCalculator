//
//  AESignUpViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AESignUpViewController : UIViewController <NSURLConnectionDelegate,UIImagePickerControllerDelegate>{
    NSMutableData *_responseData;
    NSString *base64string;
    NSMutableDictionary *userInfo;
}

@property IBOutlet UIImageView *imageView;
@property IBOutlet UIScrollView *scrollView;
@property IBOutlet UITextField *email;
@property IBOutlet UITextField *password;
@property IBOutlet UITextField *passwordConfirm;
@property IBOutlet UITextField *handle;
@property IBOutlet UITextField *zip;
@property IBOutlet UITextField *owner;
@property IBOutlet UITextField *gender;
@property IBOutlet UITextField *size;
@property IBOutlet UITextField *spayed;
@property IBOutlet UITextField *personality;
@property IBOutlet UIView *contentView;
@end
