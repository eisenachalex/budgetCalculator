//
//  AEFriendsViewController.h
//  Sketch
//
//  Created by Alex Eisenach on 4/27/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AEActiveFriendsViewControllerDelegate;
@interface AEActiveFriendsViewController : UITableViewController <NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
    NSArray *friendsArray;
    NSMutableArray *userInfo;
    
    
}
@property(weak) id <AEActiveFriendsViewControllerDelegate> delegate;


@end



@protocol AEActiveFriendsViewControllerDelegate <NSObject>
- (void)controller:(AEActiveFriendsViewController *)controller didSelectUserWithName:(NSString *)name;
@end
