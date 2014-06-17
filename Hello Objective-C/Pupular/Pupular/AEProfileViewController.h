//
//  AEProfileViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEProfileViewController : UIViewController <NSURLConnectionDelegate>{
    NSMutableData *_responseData;
    NSMutableDictionary *profile;
    NSMutableDictionary *userInfo;
}
@property NSString *dogID;
@property BOOL *isFriend;
@property BOOL *isMine;
@property NSString *dogHandle;
@property IBOutlet UINavigationItem *navBar;
@property IBOutlet UILabel *location;
@property IBOutlet UILabel *age;
@property IBOutlet UILabel *personality;
@property IBOutlet UILabel *gender;
@property IBOutlet UILabel *owners_name;
@property IBOutlet UILabel *breed;
@property IBOutlet UILabel *size;
@property IBOutlet UIButton *actionButton;
@end
