//
//  AEHomeMapViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "AEHomeMapViewController.h"
#import "AETargetMapViewController.h"
#import "AEMenuViewController.h"
#import "AEActiveFriendsViewController.h"
@interface AETargetMapViewController ()

@end

@implementation AETargetMapViewController
@synthesize mapViewContainer,trackingSwitch,target_id;
GMSMapView *mapView_;
GMSMarker *marker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"the id yo %@",target_id);

    [self loadUserInfo];
    [self retrieveActiveFriends];
    [self startTimer];
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

            if([userInfo valueForKey:@"is_active"]){
            if([[userInfo valueForKey:@"is_active"] isEqualToString:@"true"]){
                [trackingSwitch setOn:YES];
            }
            else {
                [trackingSwitch setOn:NO];
            }
        }
    NSLog(@"THE LOCATION MANAGER %@",_locationController);

}





- (void)viewDidLoad {
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:12];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 460) camera:camera];
    
    // Listen to the myLocation property of GMSMapView.
    
    
    [self.mapViewContainer addSubview:mapView_];

    mapView_.myLocationEnabled = YES;

}



-(IBAction)trackingSwitch:(id)sender{
    if([sender isOn]){
        NSLog(@"True");
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/walk_alert?dog_id=%@",[userInfo objectForKey:@"dog_id"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [_locationController.locationManager startUpdatingLocation];
        [userInfo setValue:@"true" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    else{
        NSLog(@"False");
        
        [_locationController.locationManager stopUpdatingLocation];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/deactivate?email=%@",[userInfo objectForKey:@"email"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [userInfo setValue:@"false" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    
}

- (IBAction)target:(id)sender{
    NSLog(@"MY COORDS %@",mapView_.myLocation);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mapView_.myLocation.coordinate.latitude
                                                            longitude:mapView_.myLocation.coordinate.longitude
                                                                 zoom:14];
    [mapView_ animateToCameraPosition:camera];
    
    
}

-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
    menuView.locationController = _locationController;
    [self presentViewController:menuView animated:NO completion:nil];
}

-(IBAction)list:(id)sender{
    AEActiveFriendsViewController *activeFriendsView = [[AEActiveFriendsViewController alloc] init];
    activeFriendsView.activeFriendsArray = activeFriendsArray;
    [self presentViewController:activeFriendsView animated:NO completion:nil];
}




- (void)locationUpdate:(CLLocation *)location {
    NSLog(@"request");
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/update_coordinates?lat=%f&long=%f&active=t&email=%@",location.coordinate.latitude, location.coordinate.longitude,[userInfo objectForKey:@"email"]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void)locationError:(NSError *)error {
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been receive3d
    // You can parse the stuff in your instance variable now
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    NSLog(@"JSON %@",newJSON);
    if([newJSON objectForKey:@"active_friends_list"]){
        [mapView_ clear];
        activeFriendsArray = [newJSON objectForKey:@"active_friends_list"];
        NSLog(@"we got active friends yo %@",activeFriendsArray);
        for(int i=0;i < activeFriendsArray.count; i++){
            NSDictionary *activeFriend = [activeFriendsArray objectAtIndex:i];
            NSString *lat = [activeFriend valueForKey:@"lat"];
            NSString *longitude = [activeFriend valueForKey:@"long"];
            NSString *activeFriendId = [activeFriend valueForKey:@"id"];
            float lat_coord = [lat floatValue];
            float long_coord = [longitude floatValue];
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat_coord, long_coord);
            GMSMarker *marker = [GMSMarker markerWithPosition:position];

            if([[NSString stringWithFormat:@"%@",activeFriendId] isEqualToString:[NSString stringWithFormat:@"%@",target_id]]){
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat_coord
                                                                        longitude:long_coord
                                                                             zoom:18];
                [mapView_ animateToCameraPosition:camera];
                target_id = 0;
            }
            marker.title = [activeFriend valueForKey:@"handle"];
            marker.map = mapView_;
        }
    }
    
}

-(void)retrieveActiveFriends{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/retrieve_active_friends?dog_id=%@",[userInfo objectForKey:@"dog_id"]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)loadUserInfo {
    NSString *filePath = [self pathForUserInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        
    } else {
        userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setValue:@"empty" forKey:@"email"];
    }
    NSLog(@"here is the user info %@", userInfo);
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    NSLog(@"path %@",paths);
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}


- (void) startTimer
{
    self.myTime = [NSTimer scheduledTimerWithTimeInterval:30
                                                   target:self
                                                 selector:@selector(timerFired:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void) stopTimer
{
    [self.myTime invalidate];
}

- (void) timerFired:(NSTimer*)theTimer
{
    
    
    [self retrieveActiveFriends];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
