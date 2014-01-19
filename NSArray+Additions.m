//
//  NSArray+Additions.m
//  EffortlessGroceries
//
//  Created by Justin Bartlett on 5/30/13.
//  Copyright (c) 2013 EffortlessFood, LLC. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)

+ (BOOL)isEmpty:(NSArray *)array
{
    return !array || array.count == 0;
}

+ (BOOL)isNotEmpty:(NSArray *)array
{
    return array && array.count > 0;
}

- (id)firstObject
{
    return [NSArray isNotEmpty:self] ? [self objectAtIndex:0] : nil;
}

// Split the array into a dictionary using the object at the keypath as the dictionary key.
- (NSMutableDictionary *)dictionaryWithValuesForKeyPath:(NSString *)keyPath defaultKey:(id)defaultKey
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (id object in self) {

        id dictKey = [object valueForKeyPath:keyPath];
        if (!dictKey) {
            dictKey = defaultKey;
        }
        
        NSMutableArray *dictValues = [dict objectForKey:dictKey];
        if (!dictValues) {
            dictValues = [NSMutableArray array];
            [dict setObject:dictValues forKey:dictKey];
        }
        
        [dictValues addObject:object];
    }
    return dict;
}

- (id)nilSafeObjectAtIndex:(NSUInteger)index
{
    return self.count > 0 ? [self objectAtIndex:index] : nil;
}

- (NSArray *)arrayByRemovingObject:(id)object
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];
    [array removeObject:object];
    return array;
}


- (NSArray *)arrayByRemovingObjectsFromArray:(NSArray *)objects
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];
    [array removeObjectsInArray:objects];
    return array;
}

@end
