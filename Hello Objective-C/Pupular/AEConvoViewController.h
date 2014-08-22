//
//  AEConvoViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AECLController;

@interface AEConvoViewController : UIViewController <NSURLConnectionDelegate,UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSMutableArray *userInfo;
    NSMutableData *_responseData;
    NSMutableArray *messagesArray;
}
@property BOOL *backToMenu;
@property AECLController *locationController;
@property UIImage *senderImage;
@property IBOutlet UIImageView *senderImageView;
@property NSString *dogID;
@property NSTimer *myTime;
@property IBOutlet UINavigationItem *navTitle;
@property IBOutlet UITableView *tableView;
@property NSString *dogHandle;
@property BOOL *keyBoardVisible;
@property IBOutlet UIScrollView *scrollView;
@property IBOutlet UITextField *messageResponse;
@property IBOutlet UIToolbar *toolBar;
@property BOOL *firstRequest;
@end
