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
    float price = [[self.priceTextField text] floatValue];
    [self.delegate controller:self didSaveItemWithName:name andPrice:price];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
