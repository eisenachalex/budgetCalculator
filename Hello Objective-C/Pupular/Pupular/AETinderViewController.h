//
//  AETinderViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 10/28/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TinderDelegate <NSObject>
@required
- (void)sendRequest;
-(void)decline;
@end

@interface AETinderViewController : UIViewController{
    id <TinderDelegate> _delegate;
}


@property IBOutlet UIImageView *imageView;
@property IBOutlet UILabel *label;
@property (nonatomic,strong) id delegate;
@property NSDictionary *allDogs;
@property NSDictionary *dog;
@property NSString *dogID;
@end