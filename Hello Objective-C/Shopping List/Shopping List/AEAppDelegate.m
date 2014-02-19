//
//  AEAppDelegate.m
//  Shopping List
//
//  Created by Alex Eisenach on 12/21/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import "AEAppDelegate.h"
#import "AEListViewController.h"
#import "AEItem.h"
#import "AEShoppingListViewController.h"
#import "AEViewController.h"

@implementation AEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Seed Items
    // Initialize List View Controller
    AEListViewController *listViewController = [[AEListViewController alloc] init];
    // Initialize Navigation Controller
    UINavigationController *listNavigationController = [[UINavigationController alloc] initWithRootViewController:listViewController];
    // Initialize Shopping List View Controller
    AEViewController *aw = [[AEViewController alloc] init];
    // Initialize Navigation Controller
    UINavigationController *shoppingListNavigationController = [[UINavigationController alloc] initWithRootViewController:aw];
    // Initialize Tab Bar Controller
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    // Configure Tab Bar Controller
    [tabBarController setViewControllers:@[listNavigationController, shoppingListNavigationController]];
    // Initialize Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Configure Window
    [self.window setRootViewController:tabBarController];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)seedItems {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if(![ud boolForKey:@"AEUserDefaultsSeedItems"]){
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"seed" ofType:@"plist"];
        NSArray *seedItems = [NSArray arrayWithContentsOfFile:filePath];
        NSMutableArray *items = [NSMutableArray array];
        for (int i = 0; i < [seedItems count]; i++) {
            NSDictionary *seedItem = [seedItems objectAtIndex:i];
            AEItem *item = [AEItem createItemWithName:[seedItem objectForKey:@"name"] andPrice:[[seedItem objectForKey:@"price"] floatValue]];
            [items addObject:item];
            
        }
        NSString *itemsPath = [[self documentsDirectory] stringByAppendingPathComponent:@"items.plist"];
        if ([NSKeyedArchiver archiveRootObject:items toFile:itemsPath]) {
            [ud setBool:YES forKey:@"AEUserDefaultsSeedItems"];
        }
        
        
    }
}


-(NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
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
}

@end
