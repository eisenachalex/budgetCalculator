//
//  AEProfileViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"


@interface AEFriendProfileViewController : UIViewController <NSURLConnectionDelegate>{
    NSMutableData *_responseData;
    NSMutableDictionary *profile;
    NSMutableDictionary *userInfo;
}
@property NSDictionary *profile;
@property NSString *dogID;
@property BOOL *isFriend;
@property NSDictionary *dog;
@property NSDictionary *allDogs;

@property BOOL *isMine;
@property IBOutlet UINavigationItem *navTitle;
@property NSString *dogHandle;
@property NSString *buttonStatus;
@property IBOutlet UINavigationItem *navBar;
@property IBOutlet UILabel *location;
@property UITableViewCell *tableViewCell;
@property IBOutlet UILabel *age;
@property IBOutlet UILabel *personality;
@property IBOutlet UILabel *gender;
@property UIImage *convoImage;
@property IBOutlet UILabel *owners_name;
@property IBOutlet UILabel *breed;
@property IBOutlet UILabel *size;
@property IBOutlet UILabel *spayed;
@property IBOutlet UIButton *actionButton;
@property IBOutlet UIBarButtonItem *editButton;
@property IBOutlet UILabel *label;
@property IBOutlet UIButton *packButton;
@property IBOutlet UIActivityIndicatorView *activity;
@property IBOutlet UIImageView *imageView;
@property AECLController *locationController;

@end