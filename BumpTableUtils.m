//
//  BumpTableUtils.m
//  BumpTableViewExample
//
//  Created by Indrajit Khare on 6/19/13.
//  Copyright (c) 2013 Bump Technologies Inc. All rights reserved.
//

#import "BumpTableUtils.h"

@implementation BumpTableUtils

static NSString *indentedString(NSString *s) {
    static NSString *n = @"\n";
    static NSString *nIndent = @"\n  ";
    return [s stringByReplacingOccurrencesOfString:n
                                        withString:nIndent];
}

+ (NSString *)indentedDescriptionForObject:(NSObject *)obj {
    if ([obj conformsToProtocol:@protocol(NSFastEnumeration)]) {
        NSMutableString *s = [NSMutableString stringWithString:@"{\n"];
        for (NSObject *o in (id<NSFastEnumeration>)obj) {
            [s appendFormat:@"%@\n", [[self class] indentedDescriptionForObject:o]];
        }
        [s appendString:@"}"];
        return indentedString(s);
    } else {
        return indentedString([self description]);
    }
}

+ (NSArray *)mapArray:(NSArray *)arr withBlock:(BumpTableNSArrayUtilTransform)block {
    NSMutableArray *toRet = [NSMutableArray arrayWithCapacity:[arr count]];

    for (id obj in arr) {
        [toRet addObject:block(obj)];
    }
    return toRet;
}

+ (int)reduceArray:(NSArray *)arr
           withInt:(int)starter
             block:(BumpTableNSArrayUtilCombinerInt)block {
    for (id obj in arr) {
        starter = block(starter, obj);
    }
    return starter;
}

+ (int)sumArray:(NSArray *)arr withBlock:(BumpTableNSArrayUtilIntTransform)block {
    return [[self class] reduceArray:arr withInt:0 block:^int(int soFar, id obj) {
        return soFar + block(obj);
    }];
}

+ (NSArray*)filterArray:(NSArray *)arr withBlock:(BumpTableNSArrayUtilPredicate)block {
    NSMutableArray *toRet = [NSMutableArray array];

    for (id obj in arr) {
        if (block(obj)) {
            [toRet addObject:obj];
        }
    }
    return toRet;
}

@end
