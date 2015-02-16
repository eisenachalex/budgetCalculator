//
//  AEBuddiesViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AECLController;
@interface AEBuddiesViewController : UIViewController <NSURLConnectionDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    NSMutableData *_responseData;
    NSMutableArray *friendsArray;
    NSArray *searchResults;

    NSMutableDictionary *userInfo;
}
@property AECLController *locationController;
@property IBOutlet UINavigationBar *navBar;
@property IBOutlet UIBarButtonItem *menuButton;
@property IBOutlet UIBarButtonItem *backButton;
@property IBOutlet UITableView *tableView;
@property IBOutlet UISearchBar *searchBar;
@property NSString *dogHandle;
@property NSString *foreign_dog_id;
@property IBOutlet UISwitch *trackingSwitch;

@end
