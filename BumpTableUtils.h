//
//  BumpTableUtils.h
//  BumpTableViewExample
//
//  Created by Indrajit Khare on 6/19/13.
//  Copyright (c) 2013 Bump Technologies Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^BumpTableNSArrayUtilTransform)(id obj);
typedef int(^BumpTableNSArrayUtilIntTransform)(id obj);
typedef int(^BumpTableNSArrayUtilCombinerInt)(int soFar, id obj);
typedef BOOL(^BumpTableNSArrayUtilPredicate)(id obj);

@interface BumpTableUtils : NSObject
+ (NSString *)indentedDescriptionForObject:(NSObject *)obj;
+ (NSArray *)mapArray:(NSArray *)arr withBlock:(BumpTableNSArrayUtilTransform)block;
+ (int)reduceArray:(NSArray *)arr
           withInt:(int)starter
             block:(BumpTableNSArrayUtilCombinerInt)block;
+ (int)sumArray:(NSArray *)arr withBlock:(BumpTableNSArrayUtilIntTransform)block;
+ (NSArray*)filterArray:(NSArray *)arr withBlock:(BumpTableNSArrayUtilPredicate)block;
@end
