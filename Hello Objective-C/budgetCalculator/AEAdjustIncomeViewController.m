//
//  AEAdjustIncomeViewController.m
//  budgetCalculator
//
//  Created by Alex Eisenach on 2/11/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import "AEAdjustIncomeViewController.h"

@interface AEAdjustIncomeViewController ()

@end

@implementation AEAdjustIncomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)save:(id)sender {
    float income = [[self.incomeTextField text] floatValue];
    [self.delegate controller:self didSaveItemWithIncome:income];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
