//
//  AESignUpViewController.h
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AESignUpViewController : UIViewController <NSURLConnectionDelegate,UIImagePickerControllerDelegate>{
    NSMutableData *_responseData;
    NSString *base64string;
}

@property IBOutlet UIImageView *imageView;
@end
