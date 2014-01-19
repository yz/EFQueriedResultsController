//
//  NSError+ParseFramework.m
//  EffortlessSDK
//
//  Created by Justin Bartlett on 7/8/13.
//  Copyright (c) 2013 EffortlessFood, LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import "NSError+ParseFramework.h"

@implementation NSError (ParseFramework)

+ (BOOL)isFatal:(NSError *)error
{
    return error && error.code != kPFErrorCacheMiss;  // A cache miss isn't fatal.
}

@end
