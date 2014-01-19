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
