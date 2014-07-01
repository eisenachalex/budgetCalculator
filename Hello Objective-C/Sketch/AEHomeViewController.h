//
//  AEHomeViewController.h
//  Sketch
//
//  Created by Alex Eisenach on 4/27/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"

@interface AEHomeViewController : UIViewController<AECLControllerDelegate,NSURLConnectionDelegate,UITableViewDelegate,UITableViewDataSource>
{
    AECLController *locationController;
    NSMutableData *_responseData;
    NSArray *usersArray;
    NSMutableArray *userInfo;
    NSArray *searchResults;
    NSArray *allowedArray;
    NSMutableArray *myRecents;
    NSMutableArray *current_status;
}

@property IBOutlet UILabel *statusLabel;
@property IBOutlet UITableView *tableView;
@property IBOutlet UISwitch *switcher;
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
- (IBAction)tracking_button:(id)sender;
@end
