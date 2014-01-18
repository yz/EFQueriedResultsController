//
//  EFQueriedResultsSectionInfo.m
//  EffortlessSDK
//
//  Created by Justin Bartlett on 6/15/13.
//  Copyright (c) 2013 EffortlessFood, LLC. All rights reserved.
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
