//
//  RDemoModel.m
//  RModelDemo
//
//  Created by qianfeng on 15/11/7.
//  Copyright © 2015年 qianfeng. All rights reserved.
//

#import "RDemoModel.h"
#import "RModelCreate.h"

@implementation RDemoModel

+(instancetype)demoModelWithDict:(NSDictionary *)dict
{
    return [self objectWithDictionary:dict];
}

-(NSString *)description
{
    return [self r_Description];
}


+ (NSDictionary *)objectClassInArray{
    return @{@"stories" : [RDemoStoriesModel class]};
}
@end
@implementation RDemoStoriesModel

@end


