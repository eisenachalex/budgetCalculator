//
//  AELoginViewController.h
//  Sketch
//
//  Created by Alex Eisenach on 5/1/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AELoginViewController : UIViewController <UITextFieldDelegate,UIScrollViewDelegate>  {
    NSMutableData *_responseData;
    NSMutableArray *userInfo;
    NSString *validUserName;
    NSString *validPhone;
}
@property IBOutlet UITextField *username;
@property IBOutlet UITextField *password;
@property IBOutlet UIScrollView *scrollView;
@property IBOutlet UITextField *mobilePhone;
@property IBOutlet UITextField *createUserName;
@property IBOutlet UITextField *createUserPassword;
@property IBOutlet UITextField *createUserPasswordConfirm;
@property IBOutlet UILabel *loginError;
@property IBOutlet UILabel *registerError;

- (IBAction)logIn:(id)sender;
- (IBAction)signUp:(id)sender;

@end

