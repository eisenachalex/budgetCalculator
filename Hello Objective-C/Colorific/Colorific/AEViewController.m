//
//  AEViewController.m
//  Colorific
//
//  Created by Alex Eisenach on 12/17/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import "AEViewController.h"

@interface AEViewController ()

@end

@implementation AEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)changeColor:(id)sender{
    int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    UIColor *color = [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0];
    [self.view setBackgroundColor:color];
}

@end
