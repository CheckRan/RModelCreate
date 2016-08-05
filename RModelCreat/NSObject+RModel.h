//
//  NSObject+RModel.h
//
//  Created by CheckRan on 15/10/8.
//  Copyright (c) 2015年 CheckRan. All rights reserved.
// 更新日期 : 2015-10-12 10:23

#import <Foundation/Foundation.h>

@interface NSObject (RModel)

@property (nonatomic , strong) NSMutableArray * allKeysArray;

+ (id)objectWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)loadDataWithDict:(NSDictionary *)dictionary;
+ (NSArray *)objectsWithArray:(NSArray *)array;

- (NSDictionary *)getPropertyDictionary;

/**
 *  加入模型中有 NSArray ,需要重写此方法,自己动态设置的值 会在内部调用  + (NSDictionary *)objectClassInArray; 最好此方法不要重写
 *
 *  @param dictionary 返回当前 NSArray 上一层的字典
 */
-(void)r_modelDidLoadingWithDictionary:(NSDictionary *)dictionary;

/**
 *  顶层调用此方法,打印类以及类中所有属性
 *
 *  @return 所有的 description
 */
-(NSString *)r_Description;


/**
 *  用于 r_dealSetValueKeyNotFound:andDictionary 中调用 , 例如 :dictionary[keyString] -> self.propertyName
 *
 *  @param dictionary   数据字典
 *  @param keyString    对应属性在字典中的 key
 *  @param propertyName  需要更改的属性
 */
-(void)r_FindDictionary:(NSDictionary *)dictionary
                 andKey:(NSString *)keyString
         toPropertyName:(NSString *)propertyName;

/**
 *  当有属性但是没有 字典中需要更改  默认 id -> ID \ description -> desc
 *
 *  @param propertyName  返回模型中的属性名 ID
 *  @param dictionary    对应上一层的字典
 */
-(void)r_dealSetValueKeyNotFound:(NSString *)propertyName
                   andDictionary:(NSDictionary *)dictionary;

/**
 *  模型中有数组 实现此方法 ,返回的是以数组接下来 对应的 类名字典 @{@"对应数据中的 Key":[接下来的类名 class]}
 *
 *  @return  @{@"对应数据中的 Key":<Class>"接下来的类名"}
 */
+ (NSDictionary *)objectClassInArray;
/*
 Ex :
 + (NSDictionary *)objectClassInArray{
    return @{@"data" : [RDataDataModel class]};
 }
 */


/**
 *  需要添加对源数据的处理 , 在.h 中添加属性 , 写上数据处理就可以了
 */
-(void)addMorePropertyOrSomething;
/* 把 数据 2015/11/06 22:15:37 ==>  2015/11/06
 self.showEditDate = [self.editDate substringToIndex:9];
 */


@end


