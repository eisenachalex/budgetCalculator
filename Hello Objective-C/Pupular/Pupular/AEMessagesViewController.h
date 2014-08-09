//
//  AEMessagesViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"

@interface AEMessagesViewController : UIViewController <NSURLConnectionDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSMutableData *_responseData;
    NSMutableArray *messagesArray;
    NSMutableDictionary *userInfo;
}

@property AECLController *locationController;
@property IBOutlet UITableView *tableView;
@property IBOutlet UIActivityIndicatorView *spinner;
@end