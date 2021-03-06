//
//  AEAppDelegate.m
//  budgetCalculator
//
//  Created by Alex Eisenach on 12/23/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import "AEAppDelegate.h"
#import "AEExpenseViewController.h"
#import "AEBudgetViewController.h"
#import "AEIncomeViewController.h"
#import "AEHomeViewController.h"


@implementation AEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    AEExpenseViewController *expenseViewController = [[AEExpenseViewController alloc] init];
    AEIncomeViewController *incomeViewController = [[AEIncomeViewController alloc] init];
    AEBudgetViewController *budgetViewController = [[AEBudgetViewController alloc] init];
    AEHomeViewController *homeViewController = [[AEHomeViewController alloc] init];
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    UINavigationController *expenseNavController = [[UINavigationController alloc] initWithRootViewController:expenseViewController];
    UINavigationController *incomeNavController = [[UINavigationController alloc] initWithRootViewController:incomeViewController];
        UINavigationController *budgetNavController = [[UINavigationController alloc] initWithRootViewController:budgetViewController];
    [tabBarController setViewControllers:@[homeViewController, budgetNavController, incomeNavController, expenseNavController]];
    [tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"background.png"]];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:tabBarController];
    [self.window makeKeyAndVisible];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont boldSystemFontOfSize:10.0f], UITextAttributeFont,
                                                       [UIColor grayColor], UITextAttributeTextColor,
                                                       [UIColor grayColor], UITextAttributeTextShadowColor,
                                                       [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                       nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont boldSystemFontOfSize:10.0f], UITextAttributeFont,
                                                       [UIColor greenColor], UITextAttributeTextColor,
                                                       [UIColor greenColor], UITextAttributeTextShadowColor,
                                                       [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                       nil] forState:UIControlStateHighlighted];
    return YES;
}



- (NSString *)documentsDirectory {
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
