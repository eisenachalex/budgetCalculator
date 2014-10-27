//
//  AEToolBarTestViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 10/16/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEToolBarTestViewController : UIViewController<UIToolbarDelegate,UITextFieldDelegate>
@property IBOutlet UIToolbar *toolBar;
@property IBOutlet UIButton *button;
@property IBOutlet UITextField *textField;
@end

