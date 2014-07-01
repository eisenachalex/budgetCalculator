//
//  AEFriendsViewController.h
//  Sketch
//
//  Created by Alex Eisenach on 4/27/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AEFriendsViewControllerDelegate;
@interface AEFriendsViewController : UITableViewController <NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
    NSArray *friendsArray;


}
@property(weak) id <AEFriendsViewControllerDelegate> delegate;


@end



@protocol AEFriendsViewControllerDelegate <NSObject>
- (void)controller:(AEFriendsViewController *)controller didSelectUserWithName:(NSString *)name;
@end
