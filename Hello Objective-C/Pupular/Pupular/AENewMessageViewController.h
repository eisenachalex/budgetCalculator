//
//  AENewMessageViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 6/5/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AENewMessageViewController : UIViewController <UITextViewDelegate,UITextFieldDelegate,NSURLConnectionDelegate>{
    NSMutableDictionary *userInfo;
    NSMutableData *_responseData;
    NSArray *searchResults;
    NSMutableArray *usersArray;

}
@property IBOutlet UITextField *recipient;
@property IBOutlet UITextView *message;
@end
