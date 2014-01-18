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

#import "EFQueriedResultsSectionInfo.h"
#import "NSObject+Hash.h"
#import "NSString+Additions.h"

@implementation EFQueriedResultsSectionInfo

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        
        if ([NSString isNotEmpty:name]) {
            _indexTitle = [name substringToIndex:1];
        }
        
        _name = name;
        _objects = [NSMutableArray array];
    }
    return self;
}

- (NSUInteger)numberOfObjects
{
    return self.objects.count;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToSectionInfo:other];
}

- (BOOL)isEqualToSectionInfo:(EFQueriedResultsSectionInfo *)other
{
    if (![self.indexTitle isEqualToString:other.indexTitle]) {
        return NO;
    }
    if (![self.name isEqualToString:other.name]) {
        return NO;
    }
    if (![self.objects isEqual:other.objects]) {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = 1;
    hash += [self hashObject:self.indexTitle withHash:hash];
    hash += [self hashObject:self.name withHash:hash];
    hash += [self hashObject:self.objects withHash:hash];
    return hash;
}

@end
