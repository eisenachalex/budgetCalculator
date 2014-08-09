//
//  AEActiveFriendsViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AECLController;

@interface AEActiveFriendsViewController : UIViewController  {
    NSMutableDictionary *userInfo;

}
@property AECLController *locationController;
@property NSMutableArray *activeFriendsArray;
@property IBOutlet UITableView *tableView;
@property IBOutlet UISwitch *trackingSwitch;
@property IBOutlet UIBarButtonItem *targetButton;
@property IBOutlet UINavigationItem *targetItem;
@end
