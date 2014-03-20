//
//  AEHomeViewController.h
//  budgetCalculator
//
//  Created by Alex Eisenach on 2/9/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEQuickAddViewController.h"
#import "AEQuickExpenseViewController.h"

@interface AEHomeViewController : UIViewController <AEQuickAddViewControllerDelegate,AEQuickExpenseViewControllerDelegate>
@property IBOutlet UILabel *dailyBudget;
@property IBOutlet UILabel *month;
-(IBAction)addItem:(id)sender;
-(IBAction)addExpense:(id)sender;
@end
