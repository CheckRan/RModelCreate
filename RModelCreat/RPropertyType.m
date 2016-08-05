//
//  RPropertyType.m
//
//  Created by CheckRan on 15/10/8.
//  Copyright (c) 2015年 CheckRan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPropertyType.h"
#import "JXCommonDefine.h"

@implementation RPropertyType

+(id)propertyTypeWithKeyString:(NSString *)string
{
    RPropertyType * propertyType = [[self alloc]init];
    if ([string rangeOfString:@","].location == NSNotFound || [string rangeOfString:@","].location < 4 ) {
        return propertyType;
    }
    NSRange range = NSMakeRange(3, [string rangeOfString:@","].location - 4);
    NSString * subString = [string substringWithRange:range];
    
    propertyType.keyString = subString;
    return propertyType;
}

+(id)propertyTypeWithClassName:(NSString *)className
{
    RPropertyType * propertyType = [[self alloc] init];
    propertyType.keyString = className;
    return propertyType;
}

-(void)setKeyString:(NSString *)keyString
{
    
    _keyString = keyString;
    
    //判断数据类型
    
    _numberType = YES;
    
    if (keyString.length) {
        if ([self judgeStringContait:keyString containsString:@"NS"]) {
            self.foundationType = NSClassFromString(keyString);
        }
        else
        {
            Class clazz = NSClassFromString(keyString);
            self.customType = clazz;
        }
    }
}

- (BOOL)judgeStringContait:(NSString *)keyString containsString:(NSString *)string
{
    if (IOS_VERSION >= 9.0) {
        return [keyString localizedStandardContainsString:string];
    }
    else if (IOS_VERSION >= 8.0)
    {
        return [keyString containsString:string];
    }
    else
    {
        return [keyString rangeOfString:string].location != NSNotFound;
    }
}


@end
