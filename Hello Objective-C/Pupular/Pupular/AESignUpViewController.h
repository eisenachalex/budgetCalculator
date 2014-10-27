//
//  AESignUpViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//
#import <UIKit/UIKit.h>
@protocol DisDelegate <NSObject>
@required
- (void) dismissMe;
@end


@interface AESignUpViewController : UIViewController <NSURLConnectionDelegate,UIImagePickerControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UIScrollViewDelegate>{
    NSMutableData *_responseData;
    NSString *base64string;
    NSMutableDictionary *userInfo;
    id <DisDelegate> _delegate;
}

@property (nonatomic,strong) id delegate;

-(void)startSampleProcess;

@property IBOutlet UILabel *statusLabel;
@property IBOutlet UIActivityIndicatorView *spinner;
@property IBOutlet UIImageView *imageView;
@property IBOutlet UIScrollView *scrollView;
@property IBOutlet UITextField *email;
@property IBOutlet UITextField *location;
@property BOOL *isSignedUp;
@property IBOutlet UITextField *password;
@property IBOutlet UITextField *passwordConfirm;
@property IBOutlet UITextField *handle;
@property IBOutlet UITextField *zip;
@property IBOutlet UIButton *submitButton;
@property IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic)          NSMutableArray *pickerArray;


@end
