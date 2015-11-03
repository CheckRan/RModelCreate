//
//  NSObject+RModel.h
//  02-Model封装
//
//  Created by qianfeng on 15/10/8.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RModel)

+(id)objectWithDictionary:(NSDictionary *)dictionary;
-(id)initWithDictionary:(NSDictionary *)dictionary;
+(NSArray *)objectsWithArray:(NSArray *)array;

/**
 *  加入模型中有 NSArray ,需要重写此方法,自己动态设置的值 会在内部调用  + (NSDictionary *)objectClassInArray; ,最好此方法不要重写
 *
 *  @param dictionary 返回当前 NSArray 上一层的字典
 *  @param allKeysArray 统计出现过的 Key  假如出现了,请移出对应的 key(@"id") [allKeysArray removeObject:@"id"];
 *
 *  @return 在此函数中 减少的 key , 返回allKeysArray数组
 */
-(NSMutableArray *)r_modelDidLoadingWithDictionary:(NSDictionary *)dictionary
                                   andAllKeysArray:(NSMutableArray *)allKeysArray;

/**
 *  顶层调用此方法
 *
 *  @return 所有的 description
 */
-(NSString *)r_Description;

/**
 *  当有属性但是没有 字典中需要更改  默认 id -> ID \ description -> desc
 *
 *  @param propertyName  返回模型中的属性名 ID
 *  @param dictionary    对应上一层的字典
 *  @param allKeysArray  统计出现过的 Key  假如出现了,请移出对应的 key(@"id") [allKeysArray removeObject:@"id"];
 *
 *  @return 在此函数中 减少的 key , 返回allKeysArray数组
 */
-(NSMutableArray *)r_dealSetValueKeyNotFound:(NSString *)propertyName
                               andDictionary:(NSDictionary *)dictionary
                             andAllKeysArray:(NSMutableArray *)allKeysArray;

/**
 *  模型中又数组 实现此方法 ,返回的是以数组接下来 对应的 类名字典 @{@"对应数据中的 Key":<Class>"接下来的类名"}
 *
 *  @return  @{@"对应数据中的 Key":<Class>"接下来的类名"}
 */
+ (NSDictionary *)objectClassInArray;

//Ex : + (NSDictionary *)objectClassInArray{
//          return @{@"data" : [RDataDataModel class]};
//      }

-(void)addMorePropertyOrSomething;

@end


