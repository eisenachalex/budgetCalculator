//
//  AEQuickAddViewController.h
//  budgetCalculator
//
//  Created by Alex Eisenach on 2/20/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol AEQuickExpenseViewControllerDelegate;
@interface AEQuickExpenseViewController : UIViewController
@property(weak) id <AEQuickExpenseViewControllerDelegate> delegate;
@property IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UIPickerView *myPickerView;
@property IBOutlet UITextField *priceTextField;
@property IBOutlet UILabel *viewTitle;
@property NSString *viewTitleValue;
@property NSMutableString *storedValue;
-(IBAction)save:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)cancelEditingForView:(id)sender;

@end


@protocol AEQuickExpenseViewControllerDelegate <NSObject>
- (void)controller:(AEQuickExpenseViewController *)controller didSaveExpenseItemWithName:(NSString *)name andPrice:(float)price;
@end