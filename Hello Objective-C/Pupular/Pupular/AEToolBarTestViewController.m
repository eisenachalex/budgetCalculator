//
//  AEToolBarTestViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 10/16/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEToolBarTestViewController.h"

@interface AEToolBarTestViewController ()

@end

@implementation AEToolBarTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _toolBar.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{

}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    float y = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - _toolBar.frame.size.height;
    [_toolBar setFrame:CGRectMake(0, y-415, _toolBar.bounds.size.width, _toolBar.bounds.size.height)];}


-(IBAction)didChange:(id)sender {
    float y = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - _toolBar.frame.size.height;
    [_toolBar setFrame:CGRectMake(0, y-415, _toolBar.bounds.size.width, _toolBar.bounds.size.height)];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
