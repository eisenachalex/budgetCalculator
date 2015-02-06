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
#import "AELoginViewController.h"
#import "AEMessagesViewController.h"
#import "UIImageView+WebCache.h"
#import "AEConvoViewController.h"
#import "AEAppDelegate.h"
#import "CustomInfoWindow.h"
#import "AEFriendProfileViewController.h"

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
        self.title = @"Home";
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadUserInfo];
    [self startTimer];
    NSString *currentImage = [userInfo valueForKey:@"image_url"];
    if(![currentImage isEqualToString:_imageURL]){
        [self setThumbImage];
        _imageURL = [userInfo valueForKey:@"image_url"];
    }
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _targetID = appDelegate.targetID;
    _mapHasTarget = appDelegate.mapHasTarget;
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

- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if(_timerOff){
        [self startTimer];
    }
}


-(void)setThumbImage{
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"image_url"]]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage *image = [UIImage imageWithData:imageData];
    

    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    [face addTarget:self action:@selector(target:) forControlEvents:UIControlEventTouchUpInside];
    
    face.imageView.clipsToBounds = YES;
    face.imageView.image = nil;
    face.imageView.layer.cornerRadius = 18;
    face.bounds = CGRectMake( 0, 0, 35, 35 );

    [face setImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *faceBtn = [[UIBarButtonItem alloc] initWithCustomView:face];
    [_targetItem setLeftBarButtonItem:faceBtn];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewWillAppear:YES];
    [self loadUserInfo];
    _imageURL = [userInfo valueForKey:@"image_url"];
    [self setThumbImage];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:12];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 460) camera:camera];
    mapView_.userInteractionEnabled = YES;
    mapView_.delegate = self;
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
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    }
}

-(IBAction)trackingSwitch:(id)sender{

    [self.delegate switched];

}

- (IBAction)target:(id)sender{
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
            marker.icon = [UIImage imageNamed:@"pupular_marker_icon.png"];
            NSString *imageString = imageString = [activeFriend valueForKey:@"photo"];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageString]];
            if(_mapHasTarget){
            if([[NSString stringWithFormat:@"%@",activeFriendId] isEqualToString:[NSString stringWithFormat:@"%@",_targetID]]){

                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat_coord
                                                                        longitude:long_coord
                                                                             zoom:18];
                [mapView_ animateToCameraPosition:camera];
                _targetID = @"DEFAULT";
            }
            }
        }
    }
}

- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    AEFriendProfileViewController *profileView = [[AEFriendProfileViewController alloc] init];
    for(int i=0; i < [activeFriendsArray count]; i++){
        NSDictionary *activeFriend = [activeFriendsArray objectAtIndex:i];
        NSString *thisHandle = [activeFriend valueForKey:@"handle"];
        NSString *photoURL = [activeFriend objectForKey:@"photo_list"][1];
        if([photoURL isEqualToString:@"none"]){
            profileView.convoImage = [UIImage imageNamed:@"git_icon_hover.png"];
        }
        else{
            UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
            profileView.convoImage = image;
            
        }        NSString *dogID = [[NSString alloc] init];
        NSString *markerHandle = marker.title;
        if([thisHandle isEqualToString:markerHandle]){
            dogID = [activeFriend valueForKey:@"id"];
            profileView.dogID = dogID;
        }
    }
    profileView.isFriend = YES;
    profileView.dogHandle = [NSString stringWithFormat:@"%@",marker.title];
    profileView.imageView.image = _profileImage;
    [self presentViewController:profileView animated:YES completion:nil];
}

-(void)retrieveActiveFriends{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/retrieve_active_friends?dog_id=%@&small_photo=yes",[userInfo objectForKey:@"dog_id"]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    CustomInfoWindow *infoWindow =  [[[NSBundle mainBundle] loadNibNamed:@"markerView" owner:self options:nil] objectAtIndex:0];
   infoWindow.label.text = marker.title;
    infoWindow.image.clipsToBounds = YES;
    infoWindow.layer.cornerRadius = 20;
    infoWindow.image.layer.cornerRadius = 18;
    NSString *targetHandle = infoWindow.label.text;
    for(int i=0; i < [activeFriendsArray count]; i++){
        NSDictionary *activeFriend = [activeFriendsArray objectAtIndex:i];
        NSString *thisHandle = [activeFriend valueForKey:@"handle"];
        if([thisHandle isEqualToString:targetHandle]){
            NSString *photoURL = [activeFriend valueForKey:@"photo"];
            if([photoURL isEqualToString:@"none"]){
                [infoWindow.image setImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
            }
            else{
                [infoWindow.image setImageWithURL:[NSURL URLWithString:photoURL]
                               placeholderImage:[UIImage imageNamed:@"pupular_dog_avatar_thumb.png"]];
            }
            _profileImage = infoWindow.image.image;
        }
    }
    [self stopTimer];
    return infoWindow;
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
    self.myTime = [NSTimer scheduledTimerWithTimeInterval:5
                                                   target:self
                                                 selector:@selector(timerFired:)
                                                 userInfo:nil
                                                  repeats:YES];
    _timerOff = NO;
}

- (void) stopTimer
{
    [self.myTime invalidate];
    _timerOff = YES;
}

- (void) timerFired:(NSTimer*)theTimer
{
    [self retrieveActiveFriends];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
