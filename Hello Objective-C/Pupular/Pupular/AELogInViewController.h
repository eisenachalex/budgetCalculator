//
//  AELogInViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"

@protocol LoginDelegate <NSObject>
@required
- (void)loginComplete;
@end

@interface AELogInViewController : UIViewController <UITextFieldDelegate,UIScrollViewDelegate>{
    NSMutableData *_responseData;
    NSMutableDictionary *userInfo;
    id <LoginDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;
@property IBOutlet UIActivityIndicatorView *spinner;
@property IBOutlet UITextField *email;
@property IBOutlet UITextField *password;
@property IBOutlet UILabel *loginError;
@property IBOutlet UIScrollView *scrollView;

@end
