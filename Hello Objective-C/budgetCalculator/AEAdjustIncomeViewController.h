//
//  AEAdjustIncomeViewController.h
//  budgetCalculator
//
//  Created by Alex Eisenach on 2/11/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AEAdjustIncomeViewControllerDelegate;
@interface AEAdjustIncomeViewController : UIViewController

@property(weak) id<AEAdjustIncomeViewControllerDelegate> delegate;
@property IBOutlet UITextField *incomeTextField;
@end


@protocol AEAdjustIncomeViewControllerDelegate <NSObject>
- (void)controller:(AEAdjustIncomeViewController *)controller didSaveItemWithIncome:(float)income;
@end