//
//  RPropertyType.h
//  02-Model封装
//
//  Created by qianfeng on 15/10/8.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPropertyType : NSObject

/**
 *  是否是基本数据类型
 */
@property( nonatomic , assign ,getter = isNumberType) BOOL numberType;
/**
 *  是否是 Foundation 框架下的
 */
@property( nonatomic , assign) Class foundationType;
/**
 *  自定制
 */
@property( nonatomic , assign ) Class customType;


@property( nonatomic , copy ) NSString * keyString;

/**
 *  传入一个包含属性的数据
 *
 *  @param string 传入属性的
 *
 *  @return <#return value description#>
 */
+(id)propertyTypeWithKeyString:(NSString *)string;


+(id)propertyTypeWithClassName:(NSString *)className;

@end
