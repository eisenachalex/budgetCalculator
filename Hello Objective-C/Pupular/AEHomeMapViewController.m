//
//  AEHomeMapViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEHomeMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AEMenuViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AEMessagesViewController.h"
#import "UIImageView+WebCache.h"
#import "AEConvoViewController.h"
#import "AEAppDelegate.h"


@interface AEHomeMapViewController ()

@end

@implementation AEHomeMapViewController
@synthesize mapViewContainer,trackingSwitch;
GMSMapView *mapView_;
GMSMarker *marker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Home";

    }
    return self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self loadUserInfo];
    [self startTimer];
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _targetID = appDelegate.targetID;
    _mapHasTarget = appDelegate.mapHasTarget;

    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"image_url"]]];
    NSLog(@"user jowns %@",[userInfo objectForKey:@"image_url"]);
    NSLog(@"we got that imageurl %@",imageURL);
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage *image = [UIImage imageWithData:imageData];


    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    [face addTarget:self action:@selector(target:) forControlEvents:UIControlEventTouchUpInside];

    face.imageView.clipsToBounds = YES;
    face.imageView.layer.cornerRadius = 18;
    face.bounds = CGRectMake( 0, 0, 35, 35 );
    [face setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *faceBtn = [[UIBarButtonItem alloc] initWithCustomView:face];
    [_targetItem setLeftBarButtonItem:faceBtn];
    if([userInfo valueForKey:@"is_active"]){
        if([[userInfo valueForKey:@"is_active"] isEqualToString:@"true"]){
            [trackingSwitch setOn:YES];
        }
        else{
            [trackingSwitch setOn:NO];
        }
    }
    [self retrieveActiveFriends];
}



-(void)viewWillDisappear:(BOOL)animated{
    [self stopTimer];

}




- (void)viewDidLoad {
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:12];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 460) camera:camera];
    
    // Listen to the myLocation property of GMSMapView.
    
    
    [self.mapViewContainer addSubview:mapView_];
   

    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });


}

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



-(IBAction)trackingSwitch:(id)sender{
    if([sender isOn]){
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/walk_alert?dog_id=%@",[userInfo objectForKey:@"dog_id"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [_locationController.locationManager startUpdatingLocation];
                [userInfo setValue:@"true" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    else{

        [_locationController.locationManager stopUpdatingLocation];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/deactivate?email=%@",[userInfo objectForKey:@"email"]]]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [userInfo setValue:@"false" forKey:@"is_active"];
        [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    }
    
}

- (IBAction)target:(id)sender{
    NSLog(@"twelve twelve carrots");
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mapHasTarget = NO;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mapView_.myLocation.coordinate.latitude
                                                                longitude:mapView_.myLocation.coordinate.longitude
                                                                     zoom:14];
        [mapView_ animateToCameraPosition:camera];

    
}

-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
    menuView.locationController = _locationController;
    [self presentViewController:menuView animated:YES completion:nil];
}

-(IBAction)messages:(id)sender{
    AEMessagesViewController *messagesView = [[AEMessagesViewController alloc] init];
    messagesView.locationController = _locationController;
    
    [self presentViewController:messagesView animated:NO completion:nil];
}

-(IBAction)list:(id)sender{
    AEActiveFriendsViewController *activeFriendsView = [[AEActiveFriendsViewController alloc] init];
    activeFriendsView.activeFriendsArray = activeFriendsArray;
    activeFriendsView.locationController = _locationController;
    [self presentViewController:activeFriendsView animated:NO completion:nil];
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
    


    if([newJSON objectForKey:@"active_friends_list"]){
        [mapView_ clear];
        NSMutableArray *updatedFriendsArray = [[NSMutableArray alloc] init];
        updatedFriendsArray = [newJSON objectForKey:@"active_friends_list"];


        activeFriendsArray = updatedFriendsArray;
        for(int i=0;i < activeFriendsArray.count; i++){
            NSDictionary *activeFriend = [activeFriendsArray objectAtIndex:i];
            NSString *lat = [activeFriend valueForKey:@"lat"];
            NSString *longitude = [activeFriend valueForKey:@"long"];
            NSString *activeFriendId = [activeFriend valueForKey:@"id"];
            float lat_coord = [lat floatValue];
            float long_coord = [longitude floatValue];
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat_coord, long_coord);
            GMSMarker *marker = [GMSMarker markerWithPosition:position];
            marker.title = [activeFriend valueForKey:@"handle"];
            marker.map = mapView_;
            NSLog(@"target id %@",_targetID);
            if(_mapHasTarget){
            if([[NSString stringWithFormat:@"%@",activeFriendId] isEqualToString:[NSString stringWithFormat:@"%@",_targetID]]){
                NSLog(@"should b winning");
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat_coord
                                                                        longitude:long_coord
                                                                             zoom:18];
                [mapView_ animateToCameraPosition:camera];
                _targetID = @"DEFAULT";
            }
            }
        }
    }
    else {
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
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}


- (void) startTimer
{
    self.myTime = [NSTimer scheduledTimerWithTimeInterval:1
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
//    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
//    _hasNotification = appDelegate.hasNotification;
    [self retrieveActiveFriends];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
