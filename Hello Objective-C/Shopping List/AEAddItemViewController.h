//
//  AEAddItemViewController.h
//  Shopping List
//
//  Created by Alex Eisenach on 12/21/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AEAddItemViewControllerDelegate;

@interface AEAddItemViewController : UIViewController
@property (weak) id<AEAddItemViewControllerDelegate> delegate;
@property IBOutlet UITextField *nameTextField;
@property IBOutlet UITextField *priceTextField;
@end

@protocol AEAddItemViewControllerDelegate <NSObject>
- (void)controller:(AEAddItemViewController *)controller didSaveItemWithName:(NSString *)name andPrice:(float)price;
@end