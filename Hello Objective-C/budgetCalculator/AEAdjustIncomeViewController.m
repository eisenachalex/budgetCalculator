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

-(void)viewWillAppear:(BOOL)animated{
    NSString *value = @"";
    self.storedValue = [value mutableCopy];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"USD";
    NSLog(@"city boi %@",string);
    if(string.length == 0){
        NSString *value = @"";
        self.storedValue = [value mutableCopy];
    }
    else if (textField == self.incomeTextField)
    {
        
        
        if(string.length <= 2)
            [self.storedValue appendString:string];
        NSString *newAmount = self.storedValue;
        
        
        [textField setText:[NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:([self.storedValue intValue] *  0.01)]]]];
        return NO;
    }
    
    //Returning yes allows the entered chars to be processed
    return YES;
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    NSString *formattedString = [[self.incomeTextField text] substringFromIndex:1];
    NSString *stringWithoutCommas = [formattedString
                                     stringByReplacingOccurrencesOfString:@"," withString:@""];
    float price = [stringWithoutCommas floatValue];
    [self.delegate controller:self didSaveItemWithIncome:price];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
