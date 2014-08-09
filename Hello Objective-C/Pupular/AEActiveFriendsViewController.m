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
@synthesize activeFriendsArray, tableView,trackingSwitch;

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
    [self loadUserInfo];
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"image_url"]]];
    NSLog(@"user jowns %@",[userInfo objectForKey:@"image_url"]);
    NSLog(@"we got that imageurl %@",imageURL);
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage *image = [UIImage imageWithData:imageData];
    
    
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    [face addTarget:self action:@selector(target:) forControlEvents:UIControlEventTouchUpInside];

    face.imageView.clipsToBounds = YES;
    face.imageView.layer.cornerRadius = 25;
    face.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
    [face setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *faceBtn = [[UIBarButtonItem alloc] initWithCustomView:face];
    [_targetItem setLeftBarButtonItem:faceBtn];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadUserInfo];
    if([userInfo valueForKey:@"is_active"]){
        if([[userInfo valueForKey:@"is_active"] isEqualToString:@"true"]){
            [trackingSwitch setOn:YES];
        }
        else {
            [trackingSwitch setOn:NO];
        }
    }
}

-(IBAction)homeMapView:(id)sender{

    [self dismissViewControllerAnimated:NO completion:nil];


}


-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
    menuView.locationController = _locationController;

    [self presentViewController:menuView animated:YES completion:nil];
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
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
    if([photoURL isEqualToString:@"none"]){
        [cell.imageView setImage:[UIImage imageNamed:@"filler_icon.png"]];
    }
    else{
        [cell.imageView setImageWithURL:[NSURL URLWithString:photoURL]
                       placeholderImage:[UIImage imageNamed:@"filler_icon.png"]];
    }
    
    //messaeg button
    
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
    conversationView.locationController = _locationController;
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
    [self presentViewController:conversationView animated:NO completion:nil];
    
}

- (void)targetButtonTapped:(id)sender
{
    NSDictionary *friendDict = [activeFriendsArray objectAtIndex:[sender tag]];
    NSString *dog_id = [friendDict valueForKey:@"id"];
    NSLog(@"on the active friends view it is %@",dog_id);
    AETargetMapViewController *targetView = [[AETargetMapViewController alloc] init];
    targetView.locationController = _locationController;
    targetView.target_id = dog_id;
    [self presentViewController:targetView animated:NO completion:nil];
}

- (void)target:(id)sender
{

    AETargetMapViewController *targetView = [[AETargetMapViewController alloc] init];
    targetView.locationController = _locationController;
    targetView.target_id = [userInfo valueForKey:@"dog_id"];
    [self presentViewController:targetView animated:NO completion:nil];
}



-(IBAction)trackingSwitch:(id)sender{
    if([sender isOn])
    {
        NSLog(@"trakcing controller %@",_locationController);
        NSLog(@"True");
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/walk_alert?dog_id=%@",[userInfo objectForKey:@"dog_id"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [_locationController.locationManager startUpdatingLocation];
        [userInfo setValue:@"true" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    else{
        NSLog(@"false");
        [userInfo setValue:@"false" forKey:@"is_active"];
        
        [_locationController.locationManager stopUpdatingLocation];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/deactivate?email=%@",[userInfo objectForKey:@"email"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [userInfo setValue:@"false" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    
}




- (void)loadUserInfo {
    NSString *filePath = [self pathForUserInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        
    } else {
        userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setValue:@"empty" forKey:@"email"];
    }
    
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}


@end
