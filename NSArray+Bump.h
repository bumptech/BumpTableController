//
//  NSArray+Functional.h
//
//  Created by Indrajit Khare on 4/25/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^NSArrayUtilPredicate)(id obj);
typedef id(^NSArrayUtilTransform)(id obj);
typedef id(^NSArrayUtilCombiner)(id soFar, id obj);
typedef int(^NSArrayUtilCombinerInt)(int soFar, id obj);
typedef int(^NSArrayUtilIntTransform)(id obj);

@interface NSArray (Bump_Functional)
- (NSArray*)mapWithBlock:(NSArrayUtilTransform)block;

- (NSArray*)filterWithBlock:(NSArrayUtilPredicate)block;

- (NSArray *)filteredMapWithBlock:(NSArrayUtilTransform)block;

- (id)reduceWithInitObject:(id)initObject
                     block:(NSArrayUtilCombiner)block;

- (int)reduceWithInt:(int)starter
               block:(NSArrayUtilCombinerInt)block;

- (int)sumWithBlock:(NSArrayUtilIntTransform)block;

- (NSArray*)arrayByChunkingWithSize:(NSUInteger)chunkCapacity;

@end
