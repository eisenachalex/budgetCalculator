//
//  AEMenuViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEMenuViewController : UIViewController <NSURLConnectionDelegate,UITableViewDelegate,UITableViewDataSource> {
    NSMutableData *_responseData;
    NSArray *searchResults;
    NSMutableArray *usersArray;
    NSMutableDictionary *userInfo;
}

@end
