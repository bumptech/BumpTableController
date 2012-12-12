//
//  NSArray+Functional.m
//  Flock
//
//  Created by Indrajit Khare on 4/25/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import "NSArray+Functional.h"


@implementation NSArray (Functional)

- (NSArray*)mapWithBlock:(NSArrayUtilTransform)block {
    NSMutableArray *toRet = [NSMutableArray arrayWithCapacity:[self count]];

    for (id obj in self) {
        [toRet addObject:block(obj)];
    }
    return toRet;
}

- (NSArray*)filterWithBlock:(NSArrayUtilPredicate)block {
    NSMutableArray *toRet = [NSMutableArray array];

    for (id obj in self) {
        if (block(obj)) {
            [toRet addObject:obj];
        }
    }
    return toRet;
}

- (NSArray *)filteredMapWithBlock:(NSArrayUtilTransform)block {
    NSMutableArray *toRet = [NSMutableArray array];
    for (id obj in self) {
        id transformed = block(obj);
        if (transformed) {
            [toRet addObject:transformed];
        }
    }
    return toRet;
}

- (id)reduceWithInitObject:(id)initObject
                     block:(NSArrayUtilCombiner)block {
    for (id obj in self) {
        initObject = block(initObject, obj);
    }
    return initObject;
}

- (int)reduceWithInt:(int)starter
               block:(NSArrayUtilCombinerInt)block {
    for (id obj in self) {
        starter = block(starter, obj);
    }
    return starter;
}

- (int)sumWithBlock:(NSArrayUtilIntTransform)block {
    return [self reduceWithInt:0 block:^int(int soFar, id obj) {
        return soFar + block(obj);
    }];
}

- (NSArray*)arrayByChunkingWithSize:(NSUInteger)chunkCapacity {
    NSMutableArray *chunks = [NSMutableArray arrayWithCapacity:(int)ceil(self.count / chunkCapacity)];
    int count = [self count];
    for (int i = 0; i < count; i += chunkCapacity) {
        [chunks addObject:[self subarrayWithRange:NSMakeRange(i, MIN(chunkCapacity, count - i))]];
    }
    return chunks;
}

@end
