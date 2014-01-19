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
