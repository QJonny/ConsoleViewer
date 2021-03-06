//
//  AppDelegate.h
//  consoleViewer
//
//  Created by quarta on 26/02/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MHUnicastSocket.h"
#import "MHMulticastSocket.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;



- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)setUniSocket:(MHUnicastSocket *)socket;
- (void)setMultiSocket:(MHMulticastSocket *)socket;

@end

