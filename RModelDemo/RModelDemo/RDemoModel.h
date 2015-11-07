//
//  RDemoModel.h
//  RModelDemo
//
//  Created by qianfeng on 15/11/7.
//  Copyright © 2015年 qianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDemoStoriesModel;
@interface RDemoModel : NSObject

/**
 *  添加符合规范原则的类方法
 *
 *  @param dict  传入的 Json 字典
 *
 *  @return 反序列化之后的模型
 */
+(instancetype)demoModelWithDict:(NSDictionary *)dict;



@property (nonatomic, assign) NSInteger color;

@property (nonatomic, strong) NSArray<RDemoStoriesModel *> *stories;

@property (nonatomic, copy) NSString *image_source;

@property (nonatomic, copy) NSString *image;

//记得修改这个地方
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *background;

@property (nonatomic, copy) NSString *name;

@end
@interface RDemoStoriesModel : NSObject

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, assign) NSInteger ID;

@property (nonatomic, copy) NSString *title;

@property (nonatomic,strong) NSArray *images;

@end

