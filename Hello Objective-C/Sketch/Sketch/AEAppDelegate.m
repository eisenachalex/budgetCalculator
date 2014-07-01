//
//  AEAppDelegate.m
//  Sketch
//
//  Created by Alex Eisenach on 4/19/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEAppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AEHomeViewController.h"
#import "AEMApViewController.h"
#import "AELoginViewController.h"
#import "AEAccountSettingsViewController.h"
@implementation AEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [GMSServices provideAPIKey:@"AIzaSyAnpYPYlB5Noxyo40Ttz1PtWEgjQN48xHs"];
    // Override point for customization after application launch.
    AEMapViewController *mapView = [[AEMapViewController alloc] init];
    AEAccountSettingsViewController *accountView = [[AEAccountSettingsViewController alloc] init];
    AEHomeViewController *mainView = [[AEHomeViewController alloc] init];
    UIImage *homeImage = [[UIImage imageNamed:@"track_star_signal_OFF.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImage *mapImage = [[UIImage imageNamed:@"track_star_map_icon2.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImage *logOutImage = [[UIImage imageNamed:@"track_star_logout.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    [mainView.tabBarItem setImage:homeImage];
    [mapView.tabBarItem setImage:mapImage];
    [accountView.tabBarItem setImage:logOutImage];

    UINavigationController *mapNavController = [[UINavigationController alloc] initWithRootViewController:mapView];
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:@[mainView,mapNavController,accountView]];
    [tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"track_star_background.png"]];
  
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self loadUserInfo];
    if([[userInfo objectAtIndex:0] isEqualToString:@"empty"])
    {
        AELoginViewController *loginView = [[AELoginViewController alloc] init];
        [self.window setRootViewController:loginView];
    }
    else{
        [self.window setRootViewController:tabBarController];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of 
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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sheltered-harbor-2567.herokuapp.com/delete_session?sender=%@",[userInfo objectAtIndex:0]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];

    
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
