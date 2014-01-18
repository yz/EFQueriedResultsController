//
//  EFQueriedResultsController.h
//  EffortlessSDK
//
//  Created by Justin Bartlett on 6/15/13.
//  Copyright (c) 2013 EffortlessFood, LLC. All rights reserved.
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
