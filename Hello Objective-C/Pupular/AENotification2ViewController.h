//
//  AENotification2ViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 7/12/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"


@interface AENotification2ViewController : UIViewController{
    NSMutableArray *userInfo;
    NSMutableData *_responseData;
    NSDictionary *dogInfo;
}
@property IBOutlet UIImageView *imageView;
@property IBOutlet UIButton *actionButton1;
@property IBOutlet UIButton *actionButton2;
@property AECLController *locationController;
@property NSString *notificationType;
@property NSString *notificationMessage;
@property NSString *dogID;
@property IBOutlet UILabel *notificationTitle;
@end
