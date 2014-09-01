//
//  AEEditProfileViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/5/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEEditProfileViewController : UIViewController <UITextFieldDelegate,NSURLConnectionDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>{
    NSString *base64string;
    NSMutableData *_responseData;

}
@property NSString *dogID;
@property NSMutableDictionary *profile;
@property IBOutlet UITextField *zip;
@property IBOutlet UITextField *owner;
@property IBOutlet UITextField *breed;
@property IBOutlet UITextField *age;
@property IBOutlet UITextField *gender;
@property IBOutlet UITextField *size;
@property IBOutlet UITextField *spayed;
@property IBOutlet UITextField *personality;
@property IBOutlet UIImageView *imageView;
@property IBOutlet UIActivityIndicatorView *spinner;
@property NSMutableArray *fixedOptions;
@property UITextField *targetField;
@property IBOutlet UIView *contentView;
@property IBOutlet UIScrollView *scrollView;
@property UIImage *image;
@end
