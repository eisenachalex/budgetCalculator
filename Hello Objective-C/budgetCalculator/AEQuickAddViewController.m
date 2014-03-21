//
//  AEQuickAddViewController.m
//  budgetCalculator
//
//  Created by Alex Eisenach on 2/20/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import "AEQuickAddViewController.h"

@interface AEQuickAddViewController ()

@end

@implementation AEQuickAddViewController

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

-(void)viewWillAppear:(BOOL)animated{
    NSString *value = @"";
    self.storedValue = [value mutableCopy];
    self.viewTitle.text = self.viewTitleValue;
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
    else if (textField == self.priceTextField)
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelEditingForView:(id)sender {
    [[self view] endEditing:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self cancelEditingForView:textField]; return YES;
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)save:(id)sender {
    NSString *name = [self.nameTextField text];
    NSString *stringprice = [NSString stringWithFormat:@"%@",[self.priceTextField text]];
    NSString *formattedString = [stringprice substringFromIndex:1];
    NSString *stringWithoutCommas = [formattedString
                                     stringByReplacingOccurrencesOfString:@"," withString:@""];
    float price = [stringWithoutCommas floatValue];
    NSLog(@"AND THE PRICE %@",[self.priceTextField text]);
    [self.delegate controller:self didSaveItemWithName:name andPrice:price];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
