//
//  EFQueriedResultsSectionInfo.h
//  EffortlessSDK
//
//  Created by Justin Bartlett on 6/15/13.
//  Copyright (c) 2013 EffortlessFood, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EFQueriedResultsSectionInfo : NSObject

@property (nonatomic, readonly) NSString *indexTitle;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSUInteger numberOfObjects;
@property (nonatomic, readonly) NSMutableArray *objects;

- (id)initWithName:(NSString *)name;

@end
