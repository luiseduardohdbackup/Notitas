//
//  NotitasAppDelegate.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import "NotitasAppDelegate.h"
#import "RootViewController.h"

@interface NotitasAppDelegate (Private)
- (NSManagedObjectContext *)managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
@end

@implementation NotitasAppDelegate

+ (NotitasAppDelegate *)sharedDelegate
{
    return (NotitasAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)dealloc 
{
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [_rootController release];
    [_navController release];
	[super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    _rootController = [[RootViewController alloc] init];
	_rootController.managedObjectContext = [self managedObjectContext];
    _navController = [[UINavigationController alloc] initWithRootViewController:_rootController];
    _navController.toolbarHidden = NO;
    _navController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    _navController.navigationBarHidden = YES;
    _navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	
	[_window addSubview:[_navController view]];
    [_window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
    NSError *error;
    if (_managedObjectContext != nil) 
    {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) 
        {
			// Handle error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}

#pragma mark -
#pragma mark Saving

- (IBAction)saveAction:(id)sender 
{
    NSError *error;
    if (![[self managedObjectContext] save:&error]) 
    {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}

#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) 
    {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) 
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) 
    {
        return _managedObjectModel;
    }
    _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) 
    {
        return _persistentStoreCoordinator;
    }
	
    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Notitas.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:path];
	
	NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                   configuration:nil 
                                                             URL:storeUrl 
                                                         options:nil 
                                                           error:&error]) 
    {
        // Handle error
    }    
	
    return _persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's documents directory

- (NSString *)applicationDocumentsDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end