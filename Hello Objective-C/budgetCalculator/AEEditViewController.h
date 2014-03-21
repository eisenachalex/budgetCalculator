//
//  AEEditViewController.h
//  budgetCalculator
//
//  Created by Alex Eisenach on 3/3/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AEEditViewControllerDelegate;
@interface AEEditViewController : UIViewController
@property IBOutlet UISlider *slider;
@property IBOutlet UILabel *category;
@property IBOutlet UILabel *price;
@property NSNumber *indexNumber;
@property UIColor *labelColor;
@property (strong, nonatomic) NSString * labelText;
@property (strong, nonatomic) NSMutableArray* categoryItem;
@property IBOutlet UIProgressView *progress;
@property IBOutlet UILabel *currentPrice;
@property NSNumber *totalIncome;

-(id)initWithNibName:(NSString *)name initWithString:(NSString *)categoryName bundle:(NSBundle *)nibBundleOrNil;
@end

@protocol AEEditViewControllerDelegate <NSObject>
-(void)controller:(AEEditViewController *)controller didUpdateCategory:(NSMutableArray *)categoryItem;
@end