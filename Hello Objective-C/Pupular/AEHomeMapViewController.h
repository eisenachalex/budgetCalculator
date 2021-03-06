//
//  AEHomeMapViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"
#import <GoogleMaps/GoogleMaps.h>
@interface AEHomeMapViewController : UIViewController<AECLControllerDelegate,GMSMapViewDelegate,NSURLConnectionDataDelegate,UIGestureRecognizerDelegate>{
    NSMutableData *_responseData;
    NSMutableDictionary *userInfo;
    NSMutableArray *activeFriendsArray;
    BOOL firstLocationUpdate_;

}
@property NSTimer *myTime;
@property BOOL *hasNotification;
@property IBOutlet UINavigationBar *navBar;
@property AECLController *locationController;
@property IBOutlet UIView *mapViewContainer;
@property IBOutlet UISwitch *trackingSwitch;
@property IBOutlet UIBarButtonItem *targetButton;
@property NSString *targetID;
@property UITapGestureRecognizer *theTapRecognizer;
@property BOOL *timerOff;
@property UIImage *profileImage;
@property BOOL *mapHasTarget;
@property IBOutlet UINavigationItem *targetItem;
@end
