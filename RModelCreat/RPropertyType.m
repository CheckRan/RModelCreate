//
//  RPropertyType.m
//
//  Created by CheckRan on 15/10/8.
//  Copyright (c) 2015年 CheckRan. All rights reserved.
//

#import "RPropertyType.h"

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
        if ([keyString containsString:@"NS"]) {
            self.foundationType = NSClassFromString(keyString);
        }
        else
        {
            Class clazz = NSClassFromString(keyString);
            self.customType = clazz;
        }
    }
}

@end
