//
//  AEConvoViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEConvoViewController : UIViewController <NSURLConnectionDelegate,UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSMutableArray *userInfo;
    NSMutableData *_responseData;
    NSMutableArray *messagesArray;
}
@property NSString *dogID;
@property IBOutlet UINavigationItem *navTitle;
@property IBOutlet UITableView *tableView;
@property NSString *dogHandle;
@property IBOutlet UIScrollView *scrollView;
@property IBOutlet UITextField *messageResponse;
@property IBOutlet UIToolbar *toolBar;


@end
