//
//  NSObject+Description.m
//  Flock
//
//  Created by Ian Macartney on 5/21/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import "NSObject+Description.h"

@implementation NSObject (FLDescription)

static NSString *indentedString(NSString *s) {
    static NSString *n = @"\n";
    static NSString *nIndent = @"\n  ";
    return [s stringByReplacingOccurrencesOfString:n
                                        withString:nIndent];
}

- (NSString *)indentedDescription {
    if ([self conformsToProtocol:@protocol(NSFastEnumeration)]) {
        NSMutableString *s = [NSMutableString stringWithString:@"{\n"];
        for (NSObject *o in (id<NSFastEnumeration>)self) {
            [s appendFormat:@"%@\n", [o indentedDescription]];
        }
        [s appendString:@"}"];
        return indentedString(s);
    } else {
        return indentedString([self description]);
    }
}

@end
