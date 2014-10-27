//
//  AEMessagesViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"

@protocol SwitchDelegate <NSObject>
@required
- (void)switched;
@end
@interface AEMessagesViewController : UIViewController <NSURLConnectionDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSMutableData *_responseData;
    NSMutableArray *messagesArray;
    NSMutableDictionary *userInfo;
    id <SwitchDelegate> _delegate;

}
@property NSDictionary *allDogs;
@property NSDictionary *dog;
@property (nonatomic, strong) id delegate;
@property AECLController *locationController;
@property IBOutlet UITableView *tableView;
@property BOOL *isEditing;
@property IBOutlet UIActivityIndicatorView *spinner;
@property NSTimer *messageTime;
@property IBOutlet UISwitch *trackingSwitch;


@end

