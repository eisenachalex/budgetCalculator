//
//  AEMapViewController.m
//  Sketch
//
//  Created by Alex Eisenach on 4/27/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "AEHomeViewController.h"
#import "AEMapViewController.h"
#import "AEFriendsViewController.h"
#import "AEActiveFriendsViewController.h"

@interface AEMapViewController ()
@end

@implementation AEMapViewController
GMSMapView *mapView_;
GMSMarker *marker;

@synthesize myTime;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Map";
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUserInfo];
    response_count = 0;
    marker = [[GMSMarker alloc] init];
    UIImage *active_friends = [[UIImage imageNamed:@"track_star_people.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImage *target = [[UIImage imageNamed:@"track_star_target.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];

    self.navigationItem.RightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:active_friends style:UIBarButtonItemStyleBordered target:self action:@selector(editItems:)];
    self.navigationItem.LeftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:target style:UIBarButtonItemStyleBordered target:self action:@selector(targetItems:)];
    self.navigationItem.title = @"Tracking Map";

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:12];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];

    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    self.view = mapView_;

    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
}

-(void)viewWillAppear:(BOOL)animated{
    [self checkForFriends];
    response_count = 0;
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    }
}

-(void)checkForFriends {
    [self loadUserInfo];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/active_friends?current_user=%@",[userInfo objectAtIndex:0]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}
- (void)addFriend:(id)sender {
    AEHomeViewController *friendController = [[AEHomeViewController alloc] initWithNibName:@"AEHomeViewController" bundle:nil];
    [self presentViewController:friendController animated:YES completion:nil];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    response_count += 1;
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    NSString *latString = [newJSON valueForKey:@"lat"];
    NSString *longString = [newJSON valueForKey:@"long"];
    NSString *username = [newJSON valueForKey:@"user"];
    track_lat = [latString doubleValue];
    track_long = [longString doubleValue];
    if([[newJSON valueForKey:@"sessionLive"] isEqualToString:@"not_live"])
    {
        self.navigationItem.title = @"Session Discontinued";
        [self stopTimer];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
        marker.position = CLLocationCoordinate2DMake([latString doubleValue], [longString doubleValue]);
        marker.map = mapView_;


    }
    else if([[newJSON valueForKey:@"sessionLive"] isEqualToString:@"not_connected"])
    {
        self.navigationItem.title = @"Connection Lost";
        [self stopTimer];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
        marker.position = CLLocationCoordinate2DMake([latString doubleValue], [longString doubleValue]);
        marker.map = mapView_;

    }
    
    else if ([newJSON valueForKey:@"users"]) {
        NSMutableArray *sessions = [newJSON valueForKey:@"users"];
        if ([sessions count] > 0){
            UIImage *friends = [[UIImage imageNamed:@"track_star_people_active_red.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];

            [self.navigationItem.rightBarButtonItem setImage:friends];
        }
        else {
            UIImage *active_friends = [[UIImage imageNamed:@"track_star_people.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
            [self.navigationItem.rightBarButtonItem setImage:active_friends];

        }
    }
    else{
        marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];

        marker.position = CLLocationCoordinate2DMake([latString doubleValue], [longString doubleValue]);
        marker.map = mapView_;
        marker.title = username;
        if(response_count == 2)
        {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[latString doubleValue]
                                                                longitude:[longString doubleValue]
                                                                     zoom:14];
        [mapView_ animateToCameraPosition:camera];
        }
    }

    
}

-(void)controller:(AEFriendsViewController *)controller didSelectUserWithName:(NSString *)name
{
    activeFriend = name;
    self.navigationItem.title = [NSString stringWithFormat:@"Tracking %@",name];

    response_count = 0;
    [self startTimer];

}

-(void)editItems:(id)sender {
    AEActiveFriendsViewController *friendController = [[AEActiveFriendsViewController alloc] init];
    UINavigationController *activeFriendsNavController = [[UINavigationController alloc] initWithRootViewController:friendController];
    [friendController setDelegate:self];
    [self presentViewController:activeFriendsNavController animated:YES completion:nil];
}


-(void)targetItems:(id)sender {
    if(track_lat){
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:track_lat
                                                                longitude:track_long
                                                                     zoom:14];
        [mapView_ animateToCameraPosition:camera];

    }
    else{
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mapView_.myLocation.coordinate.latitude
                                                                longitude:mapView_.myLocation.coordinate.longitude
                                                                     zoom:14];
        [mapView_ animateToCameraPosition:camera];
        self.navigationItem.title = @"Tracking Map";

    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

- (void) startTimer
{
    self.myTime = [NSTimer scheduledTimerWithTimeInterval:5
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
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/retrieve_coordinates?username=%@&current_user=%@",activeFriend,[userInfo objectAtIndex:0]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];


}

- (void)loadUserInfo {
    NSString *filePath = [self pathForUserInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userInfo = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        AEMapViewController *loginView = [[AEMapViewController alloc] init];
        userInfo = [NSMutableArray arrayWithObjects:@"empty", nil];
        
    }
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    NSLog(@"path %@",paths);
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}
@end
