//
//  ViewController.m
//  RModelDemo
//
//  Created by qianfeng on 15/11/7.
//  Copyright © 2015年 qianfeng. All rights reserved.
//

#import "ViewController.h"
#import "RDemoModel.h"
#import <AFNetworking.h>


@interface ViewController ()

@property( nonatomic , strong ) RDemoModel * model;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //http://news-at.zhihu.com/api/4/theme/13
#define Demo_URL @"http://news-at.zhihu.com/api/4/theme/13"
    
    
    
    [self downloadDataFromAFNetworking];
    
}

/**
 *  下载数据
 */
-(void)downloadDataFromAFNetworking
{
    NSString * urlString = Demo_URL;
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        _model = [RDemoModel demoModelWithDict:dict];
        NSLog(@"_model : %@",_model);
        NSLog(@"%s",__func__);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
