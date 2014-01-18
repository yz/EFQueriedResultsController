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

#import "EFQueriedResultsController.h"
#import "EFQueriedResultsControllerDelegate.h"
#import "EFQueriedResultsSectionInfo.h"
#import "NSArray+Additions.h"
#import "NSError+ParseFramework.h"
#import "PFObject+Additions.h"

@interface EFQueriedResultsController ()

@property (nonatomic, copy) NSString *defaultSectionName;
@property (nonatomic, strong) NSArray *retrievedObjects;
@property (nonatomic, copy) NSString *sectionNameKeyPath;

@end

@implementation EFQueriedResultsController

- (id)initWithQuery:(PFQuery *)query sectionNameKeyPath:(NSString *)sectionNameKeyPath sortDescriptors:(NSArray *)sortDescriptors
{
    self = [super init];
    if (self) {
        _currentObjects = [NSArray array];
        _defaultSectionName = @"";
        _query = query;
        _retrievedObjects = [NSArray array];
        _sections = [NSMutableArray array];
        _sectionNameKeyPath = sectionNameKeyPath;
        _sortDescriptors = sortDescriptors;
    }
    return self;
}

- (void)performQueryWithBlock:(EFQueriedResultsBlock)block
{
    if (self.isQuerying) {
        NSLog(@"The query will not execute because another query is already in progress.");
        return;
    }    
    self.isQuerying = YES;
    
    __weak EFQueriedResultsController *weakSelf = self;
    [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {            
            self.retrievedObjects = objects;
            [self processObjects:objects];
        }
        else if ([NSError isFatal:error]) {
            NSLog(@"A problem occurred while finding objects for class %@: %@", weakSelf.query.parseClassName, error);
        }
        
        if (block) {
            block(!error, error);
        }
        
        self.isQuerying = NO;
    }];
}

- (NSArray *)findInsertedObjects:(NSArray *)objects
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (identifier IN %@)", [self.currentObjects valueForKeyPath:@"identifier"]];
    NSArray *insertedObjects = [objects filteredArrayUsingPredicate:predicate];
    return insertedObjects;
}

- (NSArray *)findUpdatedObjects:(NSArray *)objects
{
    NSArray *potentialObjects = [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier IN %@", [self.currentObjects valueForKeyPath:@"identifier"]]];
    NSArray *updatedObjects = [potentialObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PFObject *evaluatedObject, NSDictionary *bindings) {
        
        PFObject *existingObject = [[self.currentObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", evaluatedObject.identifier]] lastObject];
        BOOL isUpdated = [existingObject.updatedAt compare:evaluatedObject.updatedAt] == NSOrderedAscending;
        return isUpdated;
    }]];

    return updatedObjects;
}

- (NSArray *)findDeletedObjects:(NSArray *)objects
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (identifier IN %@)", [objects valueForKeyPath:@"identifier"]];
    NSArray *deletedObjects = [self.currentObjects filteredArrayUsingPredicate:predicate];
    return deletedObjects;
}

- (void)insertObjects:(NSArray *)objects
{
    [self insertObjects:objects onCompletion:nil];
}

- (void)insertObjects:(NSArray *)objects onCompletion:(EFVoidBlock)completion
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate controllerWillChangeContent:self];
        [self setRetrievedObjects:[self.retrievedObjects arrayByAddingObjectsFromArray:objects]];        
        [self processInsertedObjects:objects];
        [self.delegate controllerDidChangeContent:self];
        
        if (completion) {
            completion();
        }
    });
}

- (void)updateObjects:(NSArray *)objects
{
    [self updateObjects:objects onCompletion:nil];
}

- (void)updateObjects:(NSArray *)objects onCompletion:(EFVoidBlock)completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate controllerWillChangeContent:self];
        [self processUpdatedObjects:objects];
        [self.delegate controllerDidChangeContent:self];
        
        if (completion) {
            completion();
        }
    });
}

- (void)deleteObjects:(NSArray *)objects
{
    [self deleteObjects:objects onCompletion:nil];
}

- (void)deleteObjects:(NSArray *)objects onCompletion:(EFVoidBlock)completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate controllerWillChangeContent:self];
        [self setRetrievedObjects:[self.retrievedObjects arrayByRemovingObjectsFromArray:objects]];        
        [self processDeletedObjects:objects];
        [self.delegate controllerDidChangeContent:self];
        
        if (completion) {
            completion();
        }
    });
}

- (void)processObjects:(NSArray *)objects
{
    [self processObjects:objects onCompletion:nil];
}

- (void)processObjects:(NSArray *)objects onCompletion:(EFVoidBlock)completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate controllerWillChangeContent:self];
        [self processInsertedObjects:[self findInsertedObjects:objects]];
        [self.delegate controllerDidChangeContent:self];

        [self.delegate controllerWillChangeContent:self];
        [self processUpdatedObjects:[self findUpdatedObjects:objects]];
        [self.delegate controllerDidChangeContent:self];

        [self.delegate controllerWillChangeContent:self];
        [self processDeletedObjects:[self findDeletedObjects:objects]];
        [self.delegate controllerDidChangeContent:self];
        
        if (completion) {
            completion();
        }
    });
}

- (void)processInsertedObjects:(NSArray *)objects
{
    NSMutableArray *insertedSections = [NSMutableArray array];
    NSMutableArray *modifiedSections = [NSMutableArray array];
    
    // Insert objects into the sections.
    for (PFObject *object in objects) {
                
        NSString *sectionName = [self sectionNameForObject:object];
        EFQueriedResultsSectionInfo *sectionInfo = [[self.sections filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", sectionName]] lastObject];
        
        if (!sectionInfo) {
            sectionInfo = [[EFQueriedResultsSectionInfo alloc] initWithName:sectionName];
            [insertedSections addObject:sectionInfo];
            [self.sections addObject:sectionInfo];
        }

        [modifiedSections addObject:sectionInfo];
        [sectionInfo.objects addObject:object];
    }
    
    // Sort the sections.
    [self.sections sortUsingDescriptors:self.sortDescriptors];
    
    // Sort the objects.
    for (EFQueriedResultsSectionInfo *sectionInfo in modifiedSections) {
        [sectionInfo.objects sortUsingDescriptors:self.sortDescriptors];
    }
    
    // Notify the delegate of the section changes.
    for (EFQueriedResultsSectionInfo *sectionInfo in insertedSections) {
        NSUInteger sectionIndex = [self.sections indexOfObject:sectionInfo];
        [self.delegate controller:self didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:EFQueriedResultsChangeInsert];
    }
    
    // Notify the delegate of the object changes.
    for (PFObject *object in objects) {
        NSIndexPath *indexPath = [self indexPathForObject:object];
        [self.delegate controller:self didChangeObject:object atIndexPath:indexPath forChangeType:EFQueriedResultsChangeInsert];
    }
    
    self.currentObjects = [self.currentObjects arrayByAddingObjectsFromArray:objects];    
}

- (void)processDeletedObjects:(NSArray *)objects
{
    // Build a dictionary of indexPaths:objects for all objects that should be deleted.
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (PFObject *object in objects) {
        
        NSIndexPath *indexPath = [self indexPathForObject:object];
        PFObject *match = [self objectAtIndexPath:indexPath];   // The object may have moved to a new section so re-retrieve it to ensure we delete the old version.
        [dict setObject:match forKey:indexPath];
    }
    
    NSMutableDictionary *emptySections= [NSMutableDictionary dictionary];    
    
    // Delete all objects in the dictionary.
    for (NSIndexPath *indexPath in dict.allKeys) {
        
        // Delete the object from the section.
        PFObject *deletedObject = [dict objectForKey:indexPath];
        EFQueriedResultsSectionInfo *sectionInfo = [self sectionInfoForSection:indexPath.section];
        [sectionInfo.objects removeObject:deletedObject];
        [self.delegate controller:self didChangeObject:deletedObject atIndexPath:indexPath forChangeType:EFQueriedResultsChangeDelete];
        
        // Track empty sections.
        if ([NSArray isEmpty:sectionInfo.objects]) {
            [emptySections setObject:sectionInfo forKey:@(indexPath.section)];
        }
    }
    
    // Delete empty sections.
    for (NSNumber *sectionIndex in emptySections.allKeys) {
        EFQueriedResultsSectionInfo *sectionInfo = [emptySections objectForKey:sectionIndex];
        [self.sections removeObject:sectionInfo];
        [self.delegate controller:self didChangeSection:sectionInfo atIndex:[sectionIndex integerValue] forChangeType:EFQueriedResultsChangeDelete];
    }
    
    self.currentObjects = [self.currentObjects arrayByRemovingObjectsFromArray:objects];    
}

- (void)processUpdatedObjects:(NSArray *)objects
{
    for (PFObject *object in objects) {        
        
        EFQueriedResultsSectionInfo *sectionInfo = [self sectionInfoForObject:object];
        
        NSString *fromSectionName = sectionInfo.name;
        NSString *toSectionName = [self sectionNameForObject:object];
        
        if (![fromSectionName isEqualToString:toSectionName]) {
            [self processDeletedObjects:@[object]];
            [self processInsertedObjects:@[object]];
        }
        
        NSIndexPath *indexPath = [self indexPathForObject:object];
        [self.delegate controller:self didChangeObject:object atIndexPath:indexPath forChangeType:EFQueriedResultsChangeUpdate];
    }
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    EFQueriedResultsSectionInfo *sectionInfo = [self sectionInfoForSection:indexPath.section];
    PFObject *object = [sectionInfo.objects nilSafeObjectAtIndex:indexPath.row];
    return object;
}

- (NSIndexPath *)indexPathForObject:(PFObject *)object
{
    NSIndexPath *indexPath;    
    
    EFQueriedResultsSectionInfo *sectionInfo = [self sectionInfoForObject:object];
    
    NSUInteger sectionIndex = [self.sections indexOfObject:sectionInfo];
    NSUInteger rowIndex = [sectionInfo.objects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [((PFObject *)obj).identifier isEqualToString:object.identifier];
    }];
    
    if (sectionIndex != NSNotFound && rowIndex != NSNotFound) {
        indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    }
    
    return indexPath;
}

- (NSIndexPath *)indexPathForObjectUsingPredicate:(NSPredicate *)predicate
{
    NSIndexPath *indexPath;
    PFObject *object = [[self.currentObjects filteredArrayUsingPredicate:predicate] lastObject];
    if (object) {
        indexPath = [self indexPathForObject:object];
    }
    return indexPath;
}

- (NSString *)sectionNameForObject:(PFObject *)object
{
    NSString *sectionName = [object valueForKeyPath:self.sectionNameKeyPath];
    if (!sectionName) {
        sectionName = self.defaultSectionName;
    }
    return sectionName;
}

- (EFQueriedResultsSectionInfo *)sectionInfoForObject:(PFObject *)object
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY objects.identifier == %@", object.identifier];
    EFQueriedResultsSectionInfo *sectionInfo = [[self.sections filteredArrayUsingPredicate:predicate] lastObject];
    return sectionInfo;
}

- (EFQueriedResultsSectionInfo *)sectionInfoForSection:(NSUInteger)section
{
    EFQueriedResultsSectionInfo *sectionInfo = [self.sections nilSafeObjectAtIndex:section];
    return sectionInfo;
}

- (void)applyFilterPredicate:(NSPredicate *)predicate onCompletion:(EFVoidBlock)completion
{
    if (predicate) {
        [self processObjects:[self.retrievedObjects filteredArrayUsingPredicate:predicate] onCompletion:completion];
    }
    else {
        [self processObjects:self.retrievedObjects onCompletion:completion];
    }
}

@end