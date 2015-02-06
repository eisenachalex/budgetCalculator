//
//  AEMenuViewController.h
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

@interface AESearchViewController : UIViewController <NSURLConnectionDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate> {
    NSMutableData *_responseData;
    NSArray *searchResults;
    NSMutableArray *usersArray;
    NSMutableDictionary *userInfo;
    id <SwitchDelegate> _delegate;

}
@property (nonatomic, strong) id delegate;
@property AECLController *locationController;
@property BOOL *isFriend;
@property NSMutableDictionary *allDogs;
@property IBOutlet UIButton *tinderButton;
@property IBOutlet UILabel *orLabel;
@property NSString *nextDog;
@property NSMutableArray *remainingIDs;
@property NSMutableDictionary *revisedDogs;
@property IBOutlet UIActivityIndicatorView *spinner;
@property IBOutlet UISwitch *trackingSwitch;
@end