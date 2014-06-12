//
//  AEActiveFriendsViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEActiveFriendsViewController.h"
#import "AEHomeMapViewController.h"
#import "AEMenuViewController.h"

@interface AEActiveFriendsViewController ()

@end

@implementation AEActiveFriendsViewController

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

-(IBAction)homeMapView:(id)sender{
    AEHomeMapViewController *homeMapView = [[AEHomeMapViewController alloc] init];
    [self presentViewController:homeMapView animated:NO completion:nil];
}


-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
    [self presentViewController:menuView animated:NO completion:nil];
}

@end
