//
//  AEBuddiesViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEBuddiesViewController : UIViewController <NSURLConnectionDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSMutableData *_responseData;
    NSMutableArray *friendsArray;
    NSMutableDictionary *userInfo;
}

@property IBOutlet UITableView *tableView;
@property IBOutlet UISearchBar *searchBar;
@property NSString *foreign_dog_id;

@end
