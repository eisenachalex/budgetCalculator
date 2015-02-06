//
//  AEAppDelegate.m
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "AELogInViewController.h"
#import "AEHomeMapViewController.h"
#import "AEMessagesViewController.h"
#import "AEMenuViewController.h"
#import "AETabBarViewController.h"
#import "AESearchViewController.h"
#import "AEActiveFriendsViewController.h"
#import "AEAppDelegate.h"

@implementation AEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NewRelicAgent startWithApplicationToken:@"AA00ff3893ee8e5e9bf953db6792932529d3caacbe"];
    [self loadUserInfo];

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    [self getAllDogs];

    if([userInfo valueForKey:@"dog_id"]){
        [self getFriendList];
        [self startTimer];
    }

    _locationController = [[AECLController alloc] init];
    _locationController.delegate = self;
    _targetID = @"DEFAULT";
    _mapHasTarget = NO;
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    application.applicationIconBadgeNumber = 0;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [GMSServices provideAPIKey:@"AIzaSyAnpYPYlB5Noxyo40Ttz1PtWEgjQN48xHs"];
    AELogInViewController *loginView = [[AELogInViewController alloc] init];
    [userInfo setObject:@"false" forKey:@"is_active"];
    [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
        AEHomeMapViewController *mapView = [[AEHomeMapViewController alloc] init];
        AEMenuViewController *moreView = [[AEMenuViewController alloc] init];
        AEMessagesViewController *messageView = [[AEMessagesViewController alloc] init];
        AESearchViewController *searchView = [[AESearchViewController alloc] init];
        AEActiveFriendsViewController *packView = [[AEActiveFriendsViewController alloc] init];
        mapView.locationController = _locationController;
        messageView.locationController = _locationController;
        searchView.locationController = _locationController;
        packView.locationController = _locationController;
        mapView.view.tag = 23;
        messageView.view.tag = 12;
        UIImage *homeImage = [UIImage imageNamed:@"pupular_track_home.png"] ;
        UIImage *packImage = [UIImage imageNamed:@"pupular_pack_default.png"];
        UIImage *searchImage = [UIImage imageNamed:@"pupular_search_default.png"];
        UIImage *messageImage = [UIImage imageNamed:@"pupular_message_default.png"];
        UIImage *moreImage = [UIImage imageNamed:@"pupular_more_default.png"];
        [mapView.tabBarItem setImage:homeImage];
        [searchView.tabBarItem setImage:searchImage];
        [packView.tabBarItem setImage:packImage];
        [moreView.tabBarItem setImage:moreImage];
        [messageView.tabBarItem setImage:messageImage];
        AETabBarViewController *tabBarController = [[AETabBarViewController alloc] init];
        _tabBarController = tabBarController;
        mapView.delegate = tabBarController;
        messageView.delegate = tabBarController;
        searchView.delegate = tabBarController;
        packView.delegate = tabBarController;
        [tabBarController setViewControllers:@[mapView,packView,searchView,messageView,moreView]];
        tabBarController.locationController = _locationController;
        tabBarController.tabBar.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.1 alpha:1];
        [self.window setRootViewController:tabBarController];
        loginView.delegate = mapView;
        if([[userInfo valueForKey:@"email"] isEqualToString:@"empty"]){
            [mapView presentViewController:loginView animated:NO completion:nil];
        }
        return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *infoDict = notification.userInfo;
    NSString *messageType = [infoDict valueForKey:@"message_type"];
    application.applicationIconBadgeNumber = application.applicationIconBadgeNumber += 1;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    _applicationFromBackground = TRUE;

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self loadUserInfo];
    [userInfo setValue:@"false" forKey:@"is_active"];
    [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/deactivate?email=%@",[userInfo objectForKey:@"email"]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (void)loadUserInfo {
    NSString *filePath = [self pathForUserInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        
    }
    else {
        userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setValue:@"empty" forKey:@"email"];
    }
}


- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSMutableDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
    if(([newJSON objectForKey:@"all_dogs"])){
        _allDogs = [newJSON objectForKey:@"all_dogs"];
    }
    if(([newJSON objectForKey:@"friends"])){
        _friendList = [newJSON objectForKey:@"friends"];
    }
    if([newJSON objectForKey:@"messages"]){
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        messages = [newJSON objectForKey:@"messages"];
        if(_allMessages){
            NSMutableArray *messageBodies = [[NSMutableArray alloc] init];
            for(int i = 0; i < [_allMessages count]; i++){
                NSArray *thisMessage = [_allMessages objectAtIndex:i];
                NSDictionary *thisMessageContent = [thisMessage objectAtIndex:0];
                NSString *notificationText = [thisMessageContent objectForKey:@"body"];
                [messageBodies addObject:notificationText];
            }
            for(int i = 0; i < [messages count]; i++){
                NSArray *thisMessage = [messages objectAtIndex:i];
                NSDictionary *thisMessageContent = [thisMessage objectAtIndex:0];
                NSString *notificationText = [thisMessageContent objectForKey:@"body"];
                NSString *messageType = [thisMessageContent objectForKey:@"message_type"];
                if(![messageBodies containsObject:[NSString stringWithFormat:@"%@",notificationText]]){
                    NSString *senderID = [thisMessageContent objectForKey:@"sender_id"];
                    NSString *dogID = [userInfo valueForKey:@"dog_id"];
                    if(([senderID intValue] != [dogID intValue]) && ![messageType isEqualToString:@"auto_message"]){
                        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                        NSDate *now = [NSDate date];
                        NSDate *dateToFire = [now dateByAddingTimeInterval:1];
                        localNotification.fireDate = dateToFire;
                        localNotification.alertBody = notificationText;
                        localNotification.soundName = UILocalNotificationDefaultSoundName;
                        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:messageType, @"message_type", @"Object 2", @"Key 2", nil];
                        localNotification.userInfo = infoDict;
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                    }
                }
            }
        }
        _allMessages = [messages mutableCopy];
        int badgeCount = 0;
        _hasNotification = NO;
        for(int i = 0; i < [_allMessages count]; i ++){
            NSArray *thisMessage = [_allMessages objectAtIndex:i];
            NSDictionary *messageDict = [thisMessage objectAtIndex:0];
            int sender_id = [[messageDict objectForKey:@"sender_id"] intValue];
            int dog_id = [[userInfo objectForKey:@"dog_id"] intValue];
            if([[messageDict objectForKey:@"message_type" ] isEqualToString:@"message"]){
                if (([[messageDict objectForKey:@"read"] boolValue] == NO) && (sender_id != dog_id)){
                    badgeCount += 1;
                    _hasNotification = YES;
                }
            }
            else if ([[messageDict objectForKey:@"read"] boolValue] == NO){
                badgeCount += 1;
                _hasNotification = YES;
            }
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
    }
}
-(void) startTimer
{
    self.messageTime = [NSTimer scheduledTimerWithTimeInterval:3
                                                   target:self
                                                 selector:@selector(timerFired:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void) stopTimer
{
    [self.messageTime invalidate];
}

-(void)getAllDogs{
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/all_dogs"]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
}

-(void)getAllMessages{
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/messages?dog_id=%@",[userInfo valueForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
}


-(void)getFriendList{
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/friend_list?dog_id=%@",[userInfo valueForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
}

- (void) timerFired:(NSTimer*)theTimer
{
    [self loadUserInfo];
    [self getFriendList];
    [self getAllMessages];
    UIImage *messageImage;
    if(_hasNotification){
        messageImage = [[UIImage imageNamed:@"pupular_message_notification.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    }
    else{
        messageImage = [UIImage imageNamed:@"pupular_message_default.png"];
    }
    UITabBarItem * tabItem = [_tabBarController.tabBar.items objectAtIndex: 3];
    tabItem.image = messageImage;
}

- (void)locationUpdate:(CLLocation *)location {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/update_coordinates?lat=%f&long=%f&email=%@",location.coordinate.latitude, location.coordinate.longitude,[userInfo objectForKey:@"email"]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)locationError:(NSError *)error {
    
}

@end
