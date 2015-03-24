//
//  AppDelegate.m
//  Noty
//
//  Created by Guanqing Yan on 3/17/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSURL* uniq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if (uniq) {
        NSLog(@"icloud available at: %@",uniq);
        //[self loadDocument];
    }
    else{
        NSLog(@"icloud not available");
    }
    return YES;
}
@end
