//
//  AEAddItemViewController.m
//  budgetCalculator
//
//  Created by Alex Eisenach on 1/26/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import "AEAddItemViewController.h"

@interface AEAddItemViewController ()
@property NSMutableArray *expenses;
@property NSMutableArray *categories;
@end

@implementation AEAddItemViewController

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
    [self loadItems];
    self.categories = [NSMutableArray arrayWithObjects: @"food",@"transportation",@"rent", nil];
    // Do any additional setup after loading the view from its nib.

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

- (void)loadItems {
    NSString *filePath = [self pathForItems];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.expenses = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.expenses = [NSMutableArray array];
    }
}

- (void)loadCategories {
    NSString *filePath = [self pathForCategories];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.categories = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.categories = [NSMutableArray array];
    }
}

- (NSString *)pathForItems {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"expenses.plist"];
}

- (NSString *)pathForCategories {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"categories.plist"];
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
    float price = [stringWithoutCommas floatValue];     [self.delegate controller:self didSaveItemWithName:name andPrice:price];
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // your stuff goes here...
    [self loadCategories];
    NSString *value = @"";
    self.storedValue = [value mutableCopy];
}

@end 
