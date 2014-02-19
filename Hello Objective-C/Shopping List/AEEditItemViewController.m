//
//  AEEditItemViewController.m
//  Shopping List
//
//  Created by Alex Eisenach on 12/23/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import "AEEditItemViewController.h"
#import "AEItem.h"

@interface AEEditItemViewController ()
@property AEItem *item;
@property (weak) id<AEEditItemViewControllerDelegate> delegate;
@end

@implementation AEEditItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithItem:(AEItem *)item andDelegate:(id<AEEditItemViewControllerDelegate>)delegate {
    self = [super initWithNibName:@"AEEditItemViewController" bundle:nil];
    if (self) {
        // Set Item
        self.item = item;
        // Set Delegate
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    if (self.item) {
        [self.nameTextField setText:[self.item name]];
        [self.priceTextField setText:[NSString stringWithFormat:@"%f", [self.item price]]];
    }
}

- (void)save:(id)sender {
    NSString *name = [self.nameTextField text];
    float price = [[self.priceTextField text] floatValue];
    [self.item setName:name];
    [self.item setPrice:price];
    [self.delegate controller:self didUpdateItem:self.item];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
