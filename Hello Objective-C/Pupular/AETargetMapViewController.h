//
//  AEHomeMapViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AECLController;
@interface AETargetMapViewController : UIViewController<NSURLConnectionDataDelegate>{
    NSMutableData *_responseData;
    NSMutableDictionary *userInfo;
    NSMutableArray *activeFriendsArray;
    BOOL firstLocationUpdate_;
    
}
@property AECLController *locationController;
@property IBOutlet UISwitch *trackingSwitch;
@property NSTimer *myTime;
@property NSString *target_id;
@property IBOutlet UIView *mapViewContainer;
@property IBOutlet UIBarButtonItem *targetButton;
@property IBOutlet UINavigationItem *targetItem;
@end
