//
//  AEQuickAddViewController.h
//  budgetCalculator
//
//  Created by Alex Eisenach on 2/20/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol AEQuickAddViewControllerDelegate;
@interface AEQuickAddViewController : UIViewController
@property(weak) id <AEQuickAddViewControllerDelegate> delegate;
@property IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UIPickerView *myPickerView;
@property IBOutlet UITextField *priceTextField;

-(IBAction)save:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)cancelEditingForView:(id)sender;
@end


@protocol AEQuickAddViewControllerDelegate <NSObject>
- (void)controller:(AEQuickAddViewController *)controller didSaveItemWithName:(NSString *)name andPrice:(float)price;
@end
