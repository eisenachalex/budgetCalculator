//
//  AEActiveFriendsViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SwitchDelegate <NSObject>
@required
- (void)switched;
@end
@class AECLController;

@interface AEActiveFriendsViewController : UIViewController <NSURLConnectionDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UIGestureRecognizerDelegate>  {
    NSMutableDictionary *userInfo;
    NSMutableData *_responseData;
    NSMutableArray *friendsArray;
    NSMutableArray *usersArray;

    NSMutableArray *searchResults;
    id <SwitchDelegate> _delegate;

}
@property (nonatomic, strong) id delegate;
@property NSDictionary *allDogs;
@property UIView *fillerView;
@property NSString *imageURL;
@property AECLController *locationController;
@property NSMutableArray *activeFriendsArray;
@property BOOL *hasNotification;
@property IBOutlet UIActivityIndicatorView *spinner;
@property NSTimer *myTime;
@property IBOutlet UITableView *tableView;
@property IBOutlet UISwitch *trackingSwitch;
@property IBOutlet UIBarButtonItem *targetButton;
@property IBOutlet UINavigationItem *targetItem;
@property IBOutlet UISearchBar *searchBar;
@property BOOL *isFriend;

@end
