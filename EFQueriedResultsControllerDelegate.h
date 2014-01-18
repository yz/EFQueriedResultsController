//
// Copyright 2014 Justin Bartlett
//
// This file is part of EFQueriedResultsController.
//
// EFQueriedResultsController is free software: you can redistribute it and/or modify it 
// under the terms of the GNU General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// EFQueriedResultsController is distributed in the hope that it will be useful, but 
// WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with EFQueriedResultsController. 
// If not, see http://www.gnu.org/licenses/.
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
