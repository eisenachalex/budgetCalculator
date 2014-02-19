//
//  AEViewController.h
//  UIKit
//
//  Created by Alex Eisenach on 12/17/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEViewController : UIViewController

@property IBOutlet UILabel *myLabel;
@property IBOutlet UIButton *myButton;

-(IBAction)changeColor:(id)sender;

@end
