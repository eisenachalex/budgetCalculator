//
//  AEAppDelegate.m
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "AEAppDelegate.h"
#import "AELogInViewController.h"
#import "AEhomeMapViewController.h"

@implementation AEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadUserInfo];
    [self startTimer];
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    application.applicationIconBadgeNumber = 0;

    if (notification) {
        [self showAlarm:notification.alertBody];
        application.applicationIconBadgeNumber = 0;
    }
    


    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [GMSServices provideAPIKey:@"AIzaSyAnpYPYlB5Noxyo40Ttz1PtWEgjQN48xHs"];

    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    AELogInViewController *loginViewController = [[AELogInViewController alloc] init];
    AEHomeMapViewController *homeMapView = [[AEHomeMapViewController alloc] init];

    [self.window setRootViewController:loginViewController];
    [userInfo setObject:@"false" forKey:@"is_active"];
    [userInfo writeToFile:[self pathForUserInfo] atomically:YES];
    if([[userInfo valueForKey:@"email"] isEqualToString:@"empty"])
    {
        AELogInViewController *loginView = [[AELogInViewController alloc] init];
        [self.window setRootViewController:loginView];
    }
    else{
        [self.window setRootViewController:homeMapView];
    }
    return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self showAlarm:notification.alertBody];
    application.applicationIconBadgeNumber = application.applicationIconBadgeNumber += 1;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //[scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    
    
    return YES;
}


- (void)showAlarm:(NSString *)text {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alarm"
                                                        message:text delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been receive3d
    // You can parse the stuff in your instance variable now
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    
    if([newJSON objectForKey:@"messages"]){
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        messages = [newJSON objectForKey:@"messages"];
        if (_all_messages){
            
            if([messages count] > [_all_messages count]){
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                NSArray *thisMessage = [messages firstObject];
                NSDictionary *thisMessageContent = [thisMessage objectAtIndex:0];
                NSString *notificationText = [thisMessageContent objectForKey:@"body"];
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                
                // current time plus 10 secs
                NSDate *now = [NSDate date];
                NSDate *dateToFire = [now dateByAddingTimeInterval:5];
                localNotification.fireDate = dateToFire;
                localNotification.alertBody = notificationText;
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.applicationIconBadgeNumber += 1; // increment
                
                NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
                localNotification.userInfo = infoDict;
                
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
        }
        _all_messages = messages;
        
    }
    
    else {
    }
    
}


- (void) startTimer
{
    self.messageTime = [NSTimer scheduledTimerWithTimeInterval:5
                                                   target:self
                                                 selector:@selector(timerFired:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void) stopTimer
{
    [self.messageTime invalidate];
}

- (void) timerFired:(NSTimer*)theTimer
{
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/messages?dog_id=%@",[userInfo valueForKey:@"dog_id"]]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    
}



@end
