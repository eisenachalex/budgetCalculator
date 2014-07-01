//
//  AEAppDelegate.h
//  Sketch
//
//  Created by Alex Eisenach on 4/19/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEAppDelegate : UIResponder <UIApplicationDelegate,NSURLConnectionDelegate>{
    NSMutableData *_responseData;
    NSMutableArray *userInfo;

}

@property (strong, nonatomic) UIWindow *window;

@end
