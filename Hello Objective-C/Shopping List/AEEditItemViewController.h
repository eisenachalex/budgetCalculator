//
//  AEEditItemViewController.h
//  Shopping List
//
//  Created by Alex Eisenach on 12/23/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AEItem;
@protocol AEEditItemViewControllerDelegate;
@interface AEEditItemViewController : UIViewController
@property IBOutlet UITextField *nameTextField;
@property IBOutlet UITextField *priceTextField;
- (id)initWithItem:(AEItem *)item andDelegate:(id<AEEditItemViewControllerDelegate>)delegate;
@end

@protocol AEEditItemViewControllerDelegate <NSObject>
- (void)controller:(AEEditItemViewController *)controller didUpdateItem:(AEItem *)item;
@end
