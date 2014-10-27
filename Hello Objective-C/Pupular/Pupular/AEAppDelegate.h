//
//  AEAppDelegate.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"

@interface AEAppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDelegate> {
    NSMutableData *_responseData;
    NSMutableDictionary *userInfo;
}

@property (strong, nonatomic) UIWindow *window;
@property NSTimer *messageTime;
@property NSMutableArray *allMessages;
@property (strong, nonatomic) NSDictionary *allDogs;
@property (strong, nonatomic) NSArray *friendList;
@property BOOL *hasNotification;
@property AECLController *locationController;
@property UITabBarController *tabBarController;
@property bool applicationFromBackground;
@property NSString *targetID;
@property BOOL *mapHasTarget;
@property NSString *lastMessageID;


-(void) stopTimer;
-(void) startTimer;
-(void) getAllDogs;
@end

