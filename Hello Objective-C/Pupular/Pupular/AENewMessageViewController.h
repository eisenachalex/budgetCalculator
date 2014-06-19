//
//  AENewMessageViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/5/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AENewMessageViewController : UIViewController <UITextFieldDelegate,UITextFieldDelegate,NSURLConnectionDelegate>{
    NSMutableDictionary *userInfo;
    NSMutableData *_responseData;
    NSArray *searchResults;
    NSMutableArray *usersArray;
    NSString *receiver_id;

}
@property IBOutlet UITextField *message;
@property IBOutlet UISearchBar *searchBar;
@property IBOutlet UIScrollView *scrollView;
@end