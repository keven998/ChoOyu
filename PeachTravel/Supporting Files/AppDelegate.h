//
//  AppDelegate.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/16/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "HomeViewController.h"

#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate, IChatManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) HomeViewController *homeViewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;



@end

