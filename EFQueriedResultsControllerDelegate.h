//
//  EFQueriedResultsControllerDelegate.h
//  EffortlessSDK
//
//  Created by Justin Bartlett on 6/15/13.
//  Copyright (c) 2013 EffortlessFood, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	EFQueriedResultsChangeInsert = 1,
	EFQueriedResultsChangeDelete = 2,
	EFQueriedResultsChangeUpdate = 3
};
typedef NSUInteger EFQueriedResultsChangeType;

@class EFQueriedResultsController;
@class EFQueriedResultsSectionInfo;

@protocol EFQueriedResultsControllerDelegate <NSObject>

@optional
- (void)controllerWillChangeContent:(EFQueriedResultsController *)controller;
- (void)controllerDidChangeContent:(EFQueriedResultsController *)controller;

- (void)controller:(EFQueriedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(EFQueriedResultsChangeType)type;
- (void)controller:(EFQueriedResultsController *)controller didChangeSection:(EFQueriedResultsSectionInfo *)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(EFQueriedResultsChangeType)type;

@end
