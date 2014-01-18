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

#import <Parse/Parse.h>
#import "EFConstants.h"
#import "EFQueriedResultsControllerDelegate.h"

typedef void (^EFQueriedResultsBlock)(BOOL succeeded, NSError *error);

@class EFQueriedResultsSectionInfo;

@interface EFQueriedResultsController : NSObject

@property (nonatomic, strong) NSArray *currentObjects;
@property (nonatomic, weak) id<EFQueriedResultsControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isQuerying;
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSArray *sortDescriptors;

- (id)initWithQuery:(PFQuery *)query sectionNameKeyPath:(NSString *)sectionNameKeyPath sortDescriptors:(NSArray *)sortDescriptors;

- (void)performQueryWithBlock:(EFQueriedResultsBlock)block;
- (void)applyFilterPredicate:(NSPredicate *)predicate onCompletion:(EFVoidBlock)completion;

- (void)insertObjects:(NSArray *)objects;
- (void)insertObjects:(NSArray *)objects onCompletion:(EFVoidBlock)completion;

- (void)updateObjects:(NSArray *)objects;
- (void)updateObjects:(NSArray *)objects onCompletion:(EFVoidBlock)completion;

- (void)deleteObjects:(NSArray *)objects;
- (void)deleteObjects:(NSArray *)objects onCompletion:(EFVoidBlock)completion;

- (NSIndexPath *)indexPathForObject:(PFObject *)object;
- (NSIndexPath *)indexPathForObjectUsingPredicate:(NSPredicate *)predicate;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (EFQueriedResultsSectionInfo *)sectionInfoForSection:(NSUInteger)section;

@end
