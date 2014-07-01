//
//  AEAccountSettingsViewController.h
//  Track Star
//
//  Created by Alex Eisenach on 5/21/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEAccountSettingsViewController : UIViewController {
    NSMutableArray *userInfo;
}
@property IBOutlet UILabel *userName;
@property IBOutlet UILabel *mobilePhone;
- (IBAction)log_out:(id)sender;

@end
