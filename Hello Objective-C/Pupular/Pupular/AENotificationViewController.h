//
//  AENotificationViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AENotificationViewController : UIViewController {
    NSMutableArray *userInfo;
    NSMutableData *_responseData;
}
@property NSString *notificationType;
@property NSString *notificationMessage;
@property NSString *dogID;
@property IBOutlet UILabel *notificationTitle;
@property IBOutlet UIButton *actionButton;
@end
