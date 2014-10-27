//
//  AETabBarViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 9/11/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"

@interface AETabBarViewController : UITabBarController <NSURLConnectionDelegate,AECLControllerDelegate> {
    NSMutableDictionary *userInfo;
}
@property AECLController *locationController;
@property(nonatomic, strong) UISwitch *targetSwitch;
@end
