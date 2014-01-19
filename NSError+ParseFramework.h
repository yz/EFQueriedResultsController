//
//  NSError+ParseFramework.h
//  EffortlessSDK
//
//  Created by Justin Bartlett on 7/8/13.
//  Copyright (c) 2013 EffortlessFood, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Parse)

+ (BOOL)isFatal:(NSError *)error;

@end
