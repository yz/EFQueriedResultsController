//
//  NSArray+Additions.h
//  EffortlessGroceries
//
//  Created by Justin Bartlett on 5/30/13.
//  Copyright (c) 2013 EffortlessFood, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Additions)

+ (BOOL)isEmpty:(NSArray *)array;
+ (BOOL)isNotEmpty:(NSArray *)array;

- (id)firstObject;

- (NSMutableDictionary *)dictionaryWithValuesForKeyPath:(NSString *)keyPath defaultKey:(id)defaultKey;
- (id)nilSafeObjectAtIndex:(NSUInteger)index;

- (NSArray *)arrayByRemovingObject:(id)object;
- (NSArray *)arrayByRemovingObjectsFromArray:(NSArray *)objects;

@end
