//
//  AELogInViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AELogInViewController : UIViewController <UITextFieldDelegate,UIScrollViewDelegate>{
    NSMutableData *_responseData;
    NSMutableDictionary *userInfo;
}
@property IBOutlet UITextField *email;
@property IBOutlet UITextField *password;
@property IBOutlet UILabel *loginError;
@property IBOutlet UIScrollView *scrollView;

@end
