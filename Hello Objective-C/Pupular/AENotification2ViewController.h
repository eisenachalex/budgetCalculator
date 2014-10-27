//
//  AENotification2ViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 7/12/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"
@protocol NotificationDelegate <NSObject>
@required
- (void) notificationTargetTapped;
@end

@interface AENotification2ViewController : UIViewController <UIGestureRecognizerDelegate>{
    NSMutableArray *userInfo;
    NSMutableData *_responseData;
    NSDictionary *dogInfo;
    id <NotificationDelegate> _delegate;

}

@property (nonatomic,strong) id delegate;
@property IBOutlet UIImageView *imageView;
@property UIImage *senderThumb;
@property IBOutlet UINavigationBar *navBar;
@property IBOutlet UIButton *actionButton1;
@property IBOutlet UIButton *actionButton2;
@property NSDictionary *allDogs;
@property NSDictionary *dog;
@property AECLController *locationController;
@property NSString *notificationType;
@property NSString *notificationMessage;
@property NSString *dogID;
@property UIImage *cellImage;
@property NSString *dogHandle;
@property BOOL *isFriend;
@property IBOutlet UILabel *notificationTitle;
@end
