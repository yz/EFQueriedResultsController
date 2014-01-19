//
//  PFObject+Additions.m
//  EffortlessSDK
//
//  Created by Justin Bartlett on 7/4/13.
//  Copyright (c) 2013 EffortlessFood, LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Hash.h"
#import "PFObject+Additions.h"

@implementation PFObject (Additions)

- (NSString *)identifier
{
    static const char *Key = "Identifier";    
    
    NSString *identifier = objc_getAssociatedObject(self, Key);
    if (!identifier) {
        
        if (self.objectId) {
            identifier = self.objectId;
        }
        else {
            identifier = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
        }
        objc_setAssociatedObject(self, Key, identifier, OBJC_ASSOCIATION_RETAIN);
    }
    return identifier;
}

- (BOOL)isNotEqual:(PFObject *)other
{
    return ![self isEqual:other];
}

- (BOOL)isEqual:(PFObject *)other
{
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToOther:other];
}

- (BOOL)isEqualToOther:(PFObject *)other
{
    if (![self.identifier isEqualToString:other.identifier]) {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = 1;
    hash += [self hashObject:self.identifier withHash:hash];
    return hash;
}

@end
