//
//  AEMenuViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECLController.h"


@interface AEViewController : UIViewController <NSURLConnectionDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate> {
    NSMutableData *_responseData;
    NSArray *searchResults;
    NSMutableArray *usersArray;
    NSMutableDictionary *userInfo;
}
@property AECLController *locationController;
@property IBOutlet UIActivityIndicatorView *spinner;
@end
