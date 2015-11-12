//
//  NSObject+RModel.m
//  02-Model封装
//
//  Created by qianfeng on 15/10/8.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+RModel.h"
#import "RPropertyType.h"


@implementation NSObject (RModel)

static char key;
// 在 category 中需要重写 get 和 set 方法中
-(NSMutableArray *)allKeysArray
{
    return objc_getAssociatedObject([self class], &key);
}

-(void)setAllKeysArray:(NSMutableArray *)allKeysArray
{
    objc_setAssociatedObject([self class], &key, allKeysArray, OBJC_ASSOCIATION_RETAIN);
}

+(id)objectWithDictionary:(NSDictionary *)dictionary;
{
    return [[self alloc]initWithDictionary:dictionary];
}

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [self init]) {
        //根据类文件描述,找到当前类中, 特殊的那个属性类型,比如说 Address
        unsigned int outCount;
        objc_property_t * propertyList = class_copyPropertyList([self class], &outCount);
        
        self.allKeysArray = [dictionary.allKeys mutableCopy];

        for (int i = 0 ; i < outCount; i++ ) {
            objc_property_t property = propertyList[i];
            
            NSString * keyName = [NSString stringWithUTF8String:property_getName(property)];
            //取出也属性相关的描述 , 最重要的就是属性的数据类型
            NSString * attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
            
            id value = dictionary[keyName];
            
            RPropertyType * proType = [RPropertyType propertyTypeWithKeyString:attributes];
            
            if (proType.customType) {
                value = [proType.customType objectWithDictionary:dictionary[keyName]];
            }
            if (value == nil) {//如果字典中没有值 , 调用 r_dealSetValueKeyNotFound

                [self r_dealSetValueKeyNotFound:keyName andDictionary:dictionary];
            }
            else
            {
                [self setValue:value forKey:keyName];
                [self.allKeysArray removeObject:keyName];
            }
        }
        [self r_modelDidLoadingWithDictionary:dictionary];
        if (self.allKeysArray.count) {
            //打印数据中属性 没有出现在模型中
            [self ZJModelWithDiconary:dictionary];
        }
        [self addMorePropertyOrSomething];
        
    }
    return self;
}

-(void)addMorePropertyOrSomething
{
    
}

-(void)ZJModelWithDiconary:(NSDictionary *)dictionary
{
    printf("\n添加下列属性至 %s \n",[NSStringFromClass([self class]) UTF8String]);
    for (NSString *key in self.allKeysArray) {
//        NSString *type = ([dictionary[key] isKindOfClass:[NSNumber class]])?@"NSNumber":@"NSString";
        Class type = [dictionary[key] class];//NSString  NSNumber
        if ([type isSubclassOfClass:[NSString class]] || [type isSubclassOfClass:[NSNumber class]]) {
             NSString *typeName = ([dictionary[key] isKindOfClass:[NSNumber class]])?@"NSNumber":@"NSString";
             printf("@property (nonatomic,copy) %s *%s;\n",typeName.UTF8String,key.UTF8String);
        }
        else if([type isSubclassOfClass:[NSArray class]])
        {
            NSString *typeName = @"NSArray";
            printf("@property (nonatomic,strong) %s *%s;\n",typeName.UTF8String,key.UTF8String);
        }
        else
        {
            printf(" 属性无法判断  %s  \n",key.UTF8String);
        }
    }
    printf("\n");
}

//默认 ID -> id  desc -> description
-(void)r_dealSetValueKeyNotFound:(NSString *)propertyName andDictionary:(NSDictionary *)dictionary
{
    // ID -> id
    // ID -> Id
    if ([propertyName isEqualToString:@"ID"]) {
        [self r_FindDictionary:dictionary andKey:@"id" toPropertyName:propertyName];
    }
    else if ([propertyName isEqualToString:@"desc"])
    {
        [self r_FindDictionary:dictionary andKey:@"description" toPropertyName:propertyName];
    }
    
}

//设置值
-(void)r_FindDictionary:(NSDictionary *)dictionary andKey:(NSString *)keyString toPropertyName:(NSString *)propertyName
{
    [self setValue:dictionary[keyString] forKey:propertyName];
    [self.allKeysArray removeObject:keyString];
}

+(NSArray *)objectsWithArray:(NSArray *)array
{
    NSMutableArray * arrayM = [ NSMutableArray array];
    if (![array isKindOfClass:[NSArray class]] || !array.count) {
        return nil;
    }
    for (NSDictionary * dict in array) {
        [arrayM addObject:[self objectWithDictionary:dict]];
    }
    return arrayM;
}


-(void)r_modelDidLoadingWithDictionary:(NSDictionary *)dictionary
{
    NSDictionary * dict = [[self class] objectClassInArray];
    for (NSString * str in dict) {
        Class clazz = dict[str];
        [self setValue:[clazz objectsWithArray:dictionary[str]] forKey:str];
        [self.allKeysArray removeObject:str];
    }
}

-(NSDictionary *)objectWithobject
{
    unsigned int outCount;
    objc_property_t * propertyList = class_copyPropertyList([self class], &outCount);
    NSMutableDictionary * jsonDict = [NSMutableDictionary dictionary];
    for (int i = 0 ; i < outCount; i++ ) {
        objc_property_t property = propertyList[i];
        
        NSString * keyName = [NSString stringWithUTF8String:property_getName(property)];
        NSString * attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        RPropertyType * proType = [RPropertyType propertyTypeWithKeyString:attributes];
        id value = [self valueForKey:keyName];
        if (proType.customType) {
            value = [value objectWithobject];
        }
        [jsonDict setValue:value forKey:keyName];
    }
    return jsonDict;
}


+ (NSDictionary *)objectClassInArray{
    return nil;
}


-(NSString *)JsonStringWithDictinart
{
    NSDictionary * dict = (NSDictionary *)self;
    NSMutableString * stringM = [NSMutableString string];
    for (NSString * keyString in dict.allKeys) {
        id value = dict[keyString];
        if ([NSStringFromClass([value class]) isEqualToString:@"NSDictionary"]) {
            [stringM appendString:@"{"];
            value = [value JsonStringWithDictinart];
            [stringM appendString:@"}"];
        }
        [stringM appendFormat:@"%@:%@\n",keyString,dict[keyString]];
    }
    return stringM;
}

-(NSString *)r_Description
{    
    return [self r_DescriptionWithTCount:0];
    
}

-(NSString *)r_DescriptionWithTCount:(NSUInteger)count
{
    unsigned int outCount;
    objc_property_t * propertyList = class_copyPropertyList([self class], &outCount);
    NSMutableString * stringM = [NSMutableString string];
    [stringM appendString:@"{"];
    for (int i = 0 ; i < outCount; i++ ) {
        objc_property_t property = propertyList[i];
        NSString * keyString = [NSString stringWithUTF8String:property_getName(property)];
        NSString * attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        RPropertyType * propeType = [RPropertyType propertyTypeWithKeyString:attributes];
        if (propeType.customType) { // 自定义
            [stringM appendFormat:@"\n%@\"%@\" : %@",[self tCountWihtCount:count + 1],keyString,[[self valueForKey:keyString] r_DescriptionWithTCount:count + 1]];
        }
        else if ([propeType.foundationType isSubclassOfClass:[NSArray class]]) // 数组
        {
            [stringM appendFormat:@"\n%@\"%@\" : ",[self tCountWihtCount:count + 1],keyString];
            if ([(NSArray *)[self valueForKey:keyString] count]) {
                [stringM appendFormat:@"%@",[[self valueForKey:keyString] r_DescriptionWithTCount:count + 1]];
            }
            else
            {
                [stringM appendString:@"[]"];
            }
        }
        else //普通
        {
            [stringM appendFormat:@"\n%@\"%@\" : ",[self tCountWihtCount:count + 1],keyString];
            if ([[self valueForKey:keyString] isKindOfClass:[NSString class]]) {//NSString
                [stringM appendFormat:@"\"%@\"",[self valueForKey:keyString]];
            }
            else
            {
                id tempValue = [self valueForKey:keyString];
                if (!tempValue) {
                    tempValue = @"\"\"";
                }
                [stringM appendFormat:@"%@",tempValue];
            }
        }
    }
    [stringM appendFormat:@"\n%@}",[self tCountWihtCount:count]];
    return stringM;
}

-(NSString *)tCountWihtCount:(NSUInteger)count
{
    NSMutableString * stringM = [NSMutableString string];
    for (int i = 0 ; i < count; i++ ) {
        [stringM appendString:@"\t"];
    }
    return stringM;
}


@end

@implementation NSArray (ChineseUTF8Log)

-(NSString *)r_DescriptionWithTCount:(NSUInteger)count
{
    NSMutableString *strM = [NSMutableString stringWithString:@"["];

    for (id obj in self) {
        RPropertyType * properType = [RPropertyType propertyTypeWithClassName:NSStringFromClass([obj class])];
        if ([properType.foundationType isKindOfClass:[NSArray class]]) { //array
            [strM appendFormat:@"\n%@%@",[self tCountWihtCount:count],[obj r_DescriptionWithTCount:count + 1]];
        }
        else if (properType.foundationType) // NSString 或其他 foundation框架下的
        {
            [strM appendFormat:@"\n%@\"%@\"",[self tCountWihtCount:count],obj];
        }
        else //对象
        {
            [strM appendFormat:@"\n%@%@",[self tCountWihtCount:count],[obj r_DescriptionWithTCount:count]];
        }
    }

    [strM appendFormat:@"\n%@]",[self tCountWihtCount:count]];
    return strM;
}

-(NSString *)tCountWihtCount:(NSUInteger)count
{
    NSMutableString * stringM = [NSMutableString string];
    for (int i = 0 ; i < count; i++ ) {
        [stringM appendString:@"\t"];
    }
    return stringM;
}

@end

@implementation NSMutableArray (RModelRemove)


@end
