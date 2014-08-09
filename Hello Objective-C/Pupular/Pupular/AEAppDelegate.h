//
//  AEAppDelegate.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEAppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDelegate> {
    NSMutableData *_responseData;
    NSMutableDictionary *userInfo;
}

@property (strong, nonatomic) UIWindow *window;
@property NSTimer *messageTime;
@property NSMutableArray *all_messages;

@end
