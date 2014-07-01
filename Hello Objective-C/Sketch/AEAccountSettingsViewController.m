//
//  AEAccountSettingsViewController.m
//  Track Star
//
//  Created by Alex Eisenach on 5/21/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEAccountSettingsViewController.h"
#import "AELoginViewController.h"
@interface AEAccountSettingsViewController ()

@end

@implementation AEAccountSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Log Out";

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUserInfo];
    self.userName.text = [userInfo objectAtIndex:0];
    self.mobilePhone.text = [userInfo objectAtIndex:1];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadUserInfo {
    NSString *filePath = [self pathForUserInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userInfo = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        userInfo = [NSMutableArray arrayWithObjects:@"empty",@"blank", nil];
        
    }
}

-(void)log_out:(id)sender {
    [userInfo replaceObjectAtIndex:0 withObject:@"empty"];
    [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    AELoginViewController *loginViewController = [[AELoginViewController alloc] init];
    [self presentViewController:loginViewController animated:YES completion:nil];
}
- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    NSLog(@"path %@",paths);
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}


@end
