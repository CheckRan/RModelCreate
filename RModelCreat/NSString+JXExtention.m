//
//  NSString+JXExtention.m
//  WeJobChat
//
//  Created by CheckRan on 16/4/18.
//  Copyright © 2016年 guohu. All rights reserved.
//

#import "NSString+JXExtention.h"
#import <objc/runtime.h>

@implementation NSString (JXExtention)

/**
 *  消息转发
 *
 *  @param aSelector  方法
 *
 *  @return 执行此方法的对象
 */
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self respondsToSelector:aSelector]) {
        return self;
    }
    else
    {
        return [NSNumber numberWithInteger:self.integerValue];
    }
}

@end


@implementation NSNull (JXErrorLoad)

#define NSNullObjects @[@"",@0,@{},@[]]

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        for (NSObject *object in NSNullObjects) {
            signature = [object methodSignatureForSelector:selector];
            if (signature) {
                break;
            }
        }

    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL aSelector = [anInvocation selector];

    for (NSObject *object in NSNullObjects) {
        if ([object respondsToSelector:aSelector]) {
            [anInvocation invokeWithTarget:object];
            return;
        }
    }

    [self doesNotRecognizeSelector:aSelector];
}

@end
