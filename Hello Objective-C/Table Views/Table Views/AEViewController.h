//
//  AEViewController.h
//  Table Views
//
//  Created by Alex Eisenach on 12/19/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property NSArray *fruits;
@property NSDictionary *alphabetizedFruits;
@end
