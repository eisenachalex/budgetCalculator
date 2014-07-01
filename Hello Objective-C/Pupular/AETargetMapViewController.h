//
//  AEHomeMapViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"

@interface AETargetMapViewController : UIViewController<AECLControllerDelegate,NSURLConnectionDataDelegate>{
    AECLController *locationController;
    NSMutableData *_responseData;
    NSMutableDictionary *userInfo;
    NSMutableArray *activeFriendsArray;
    BOOL firstLocationUpdate_;
    
}
@property NSTimer *myTime;
@property NSString *target_id;
@property IBOutlet UIView *mapViewContainer;
@property IBOutlet UISwitch *trackingSwitch;
@end
