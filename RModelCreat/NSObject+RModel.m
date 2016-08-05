//
//  NSObject+RModel.m
//
//  Created by CheckRan on 15/10/8.
//  Copyright (c) 2015年 CheckRan. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+RModel.h"
#import "RPropertyType.h"
#import "JXCommonDefine.h"

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
        [self loadDataWithDict:dictionary];
    }
    return self;
}

- (void)loadDataWithDict:(NSDictionary *)dictionary
{
    //根据类文件描述,找到当前类中, 特殊的那个属性类型,比如说 Address
    unsigned int outCount;
    objc_property_t * propertyList = class_copyPropertyList([self class], &outCount);
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.allKeysArray = [dictionary.allKeys mutableCopy];
    
    for (int i = 0 ; i < outCount; i++ ) {
        objc_property_t property = propertyList[i];
        
        NSString * keyName = [NSString stringWithUTF8String:property_getName(property)];
        //取出也属性相关的描述 , 最重要的就是属性的数据类型
        NSString * attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        
        id value = dictionary[keyName];
        
        RPropertyType * proType = [RPropertyType propertyTypeWithKeyString:attributes];
        
        if (proType.customType) {
            if (dictionary[keyName]) {
                value = [proType.customType objectWithDictionary:dictionary[keyName]];
            }
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
    
    free(propertyList);
}

-(void)addMorePropertyOrSomething
{
    
}

-(void)ZJModelWithDiconary:(NSDictionary *)dictionary
{
#ifndef __OPTIMIZE__
    NSLog(@"\n添加下列属性至 %s \n",[NSStringFromClass([self class]) UTF8String]);
    for (NSString *key in self.allKeysArray) {
//        NSString *type = ([dictionary[key] isKindOfClass:[NSNumber class]])?@"NSNumber":@"NSString";
        Class type = [dictionary[key] class];//NSString  NSNumber
        if ([type isSubclassOfClass:[NSString class]] || [type isSubclassOfClass:[NSNumber class]]) {
             NSString *typeName = ([dictionary[key] isKindOfClass:[NSNumber class]])?@"NSNumber":@"NSString";
             NSLog(@"@property (nonatomic,copy) %s *%s;\n",typeName.UTF8String,key.UTF8String);
        }
        else if([type isSubclassOfClass:[NSArray class]])
        {
            NSString *typeName = @"NSArray";
            NSLog(@"@property (nonatomic,strong) %s *%s;\n",typeName.UTF8String,key.UTF8String);
        }
        else
        {
            NSLog(@" 属性无法判断  %s  \n",key.UTF8String);
        }
    }
    NSLog(@"\n");
#endif
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
    if (!dictionary[keyString]) {
        return;
    }
    [self setValue:dictionary[keyString] forKey:propertyName];
    [self.allKeysArray removeObject:keyString];
}

+(NSArray *)objectsWithArray:(NSArray *)array
{
    NSMutableArray * arrayM = [ NSMutableArray array];
    if (![array isKindOfClass:[NSArray class]]) {
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

+ (NSDictionary *)objectClassInArray{
    return nil;
}

-(NSString *)r_Description
{    
    NSDictionary * dict = [self getPropertyDictionary];
    
    return [NSObject stringWithObject:dict];
}

- (NSDictionary *)getPropertyDictionary{
    return [self r_DescriptionDictionary];
}

-(NSDictionary *)r_DescriptionDictionary
{
    unsigned int outCount;
    objc_property_t * propertyList = class_copyPropertyList([self class], &outCount);
    NSMutableDictionary * mutableDict = [NSMutableDictionary dictionary];
    
    for (int i = 0 ; i < outCount; i++ ) {
        objc_property_t property = propertyList[i];
        NSString * keyString = [NSString stringWithUTF8String:property_getName(property)];
        NSString * attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        RPropertyType * propeType = [RPropertyType propertyTypeWithKeyString:attributes];
        if (propeType.customType ||
            [propeType.foundationType isSubclassOfClass:[NSArray class]] ||
            [propeType.foundationType isSubclassOfClass:[NSDictionary class]]) { // 自定义
            //递归调用
            [mutableDict setValue:[[self valueForKey:keyString] r_DescriptionDictionary] forKey:keyString];
        }
        else //普通
        {
//            if ([[self valueForKey:keyString] isKindOfClass:[NSString class]] ||
//                [[self valueForKey:keyString] isKindOfClass:[NSNumber class]]
//                ) {
//                
//            }
//            else
//            {
//                NSLog(@"---------%@ %@",[self valueForKey:keyString], keyString);
//            }
//            [mutableDict setValue:[self valueForKey:keyString] forKey:keyString];
        }
    }
    free(propertyList);
    return mutableDict;
}

+(NSString *)stringWithObject:(id)object
{
    NSError * error = nil;
    NSData * data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return nil;
    }
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end
