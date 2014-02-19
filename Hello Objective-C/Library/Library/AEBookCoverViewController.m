//
//  AEBookCoverViewController.m
//  Library
//
//  Created by Alex Eisenach on 12/21/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import "AEBookCoverViewController.h"

@interface AEBookCoverViewController ()

@end

@implementation AEBookCoverViewController

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
        if (self.bookCover) {
            [self.bookCoverView setImage:self.bookCover];
        }
}
    // Do any additional setup after loading the view from its nib.

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
