//
//  AEAddItemViewController.h
//  budgetCalculator
//
//  Created by Alex Eisenach on 1/26/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AEAddItemViewControllerDelegate;
@interface AEAddItemViewController : UIViewController <UIPickerViewDataSource>
@property (weak) id<AEAddItemViewControllerDelegate> delegate;
@property IBOutlet UITextField *nameTextField;
@property IBOutlet UILabel *label;
@property IBOutlet UITextField *priceTextField;
@property NSMutableString *storedValue;
-(IBAction)cancelEditingForView:(id)sender;

@end


@protocol AEAddItemViewControllerDelegate <NSObject>
- (void)controller:(AEAddItemViewController *)controller didSaveItemWithName:(NSString *)name andPrice:(float)price;
@end