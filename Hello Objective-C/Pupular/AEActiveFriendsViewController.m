//
//  AEActiveFriendsViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEActiveFriendsViewController.h"
#import "AEHomeMapViewController.h"
#import "AEConvoViewController.h"
#import "AEMenuViewController.h"
#import "UIImageView+WebCache.h"
#import "AETargetMapViewController.h"
@interface AEActiveFriendsViewController ()

@end

@implementation AEActiveFriendsViewController
@synthesize activeFriendsArray, tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        activeFriendsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"active friends array: %@",activeFriendsArray);
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [activeFriendsArray count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"ITS LOADING");
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSLog(@"all the views %@",[cell.textLabel subviews]);
    for(int i = 0; i < [[cell.textLabel subviews] count]; i++){
        
        UIView *currentView = [[cell.textLabel subviews] objectAtIndex:i];
        [currentView removeFromSuperview];
        
    }
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *friendDict = [activeFriendsArray objectAtIndex:indexPath.row];
    cell.text = [friendDict objectForKey:@"handle"];
    NSString *photoURL = [friendDict objectForKey:@"photo"];
    NSLog(@"that url boi %@",photoURL);
    if([photoURL isEqualToString:@"none"]){
        [cell.imageView setImage:[UIImage imageNamed:@"git_icon_hover.png"]];
    }
    else{
        NSLog(@"yes");
        [cell.imageView setImageWithURL:[NSURL URLWithString:photoURL]
                       placeholderImage:[UIImage imageNamed:@"git_icon_hover.png"]];
    }
    
    //message button
    
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    messageButton.frame = CGRectMake(150.0, 22.5, 80.0, 50.0);
    messageButton.backgroundColor = [UIColor blackColor];
    [messageButton setTitle:@"M" forState:UIControlStateNormal];
    [messageButton addTarget:self action:@selector(messageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    messageButton.tag = indexPath.row;
    [cell addSubview:messageButton];
    
    //target button
    
    UIButton *targetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    targetButton.frame = CGRectMake(200.0, 22.5, 80.0, 50.0);
    targetButton.backgroundColor = [UIColor grayColor];
    [targetButton setTitle:@"T" forState:UIControlStateNormal];
    [targetButton addTarget:self action:@selector(targetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    targetButton.tag = indexPath.row;

    [cell addSubview:targetButton];
    
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 25;
    return cell;
}

- (void)messageButtonTapped:(id)sender
{
    NSDictionary *friendDict = [activeFriendsArray objectAtIndex:[sender tag]];
    NSString *dog_id = [friendDict valueForKey:@"id"];
    AEConvoViewController *conversationView = [[AEConvoViewController alloc] init];
    UILabel *handleLabel = [[UILabel alloc] init];
    handleLabel.text = [friendDict valueForKey:@"handle"];
    NSString *photoURL = [friendDict objectForKey:@"photo"];
    if([photoURL isEqualToString:@"none"]){
        conversationView.senderImage = [UIImage imageNamed:@"git_icon_hover.png"];
    }
    else{
        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
        conversationView.senderImage = image;

    }
    conversationView.dogHandle = handleLabel.text;
    conversationView.dogID = dog_id;
    [self presentViewController:conversationView animated:YES completion:nil];
    
}

- (void)targetButtonTapped:(id)sender
{
    NSDictionary *friendDict = [activeFriendsArray objectAtIndex:[sender tag]];
    NSString *dog_id = [friendDict valueForKey:@"id"];
    AETargetMapViewController *targetView = [[AETargetMapViewController alloc] init];
    targetView.target_id = dog_id;
    [self presentViewController:targetView animated:NO completion:nil];
}

@end
