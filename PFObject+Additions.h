//
//  PFObject+Additions.h
//  EffortlessSDK
//
//  Created by Justin Bartlett on 7/4/13.
//  Copyright (c) 2013 EffortlessFood, LLC. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFObject (Additions)

- (NSString *)identifier;

- (BOOL)isEqual:(PFObject *)other;
- (BOOL)isNotEqual:(PFObject *)other;

@end
