//
//  AEBudgetViewController.h
//  budgetCalculator
//
//  Created by Alex Eisenach on 2/9/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEAddItemViewController.h"
#import "AEAdjustIncomeViewController.h"

@interface AEBudgetViewController : UITableViewController <AEAddItemViewControllerDelegate,AEAdjustIncomeViewControllerDelegate>

@end
