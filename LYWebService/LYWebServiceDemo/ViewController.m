//
//  ViewController.m
//  LYWebServiceDemo
//
//  Created by lly on 16/8/16.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import "ViewController.h"
#import "ModuleTestApi.h"
#import "GGSafeHelper.h"
#import "LYDemoPublicParams.h"

@interface ViewController ()
@property (nonatomic,strong) UIButton *getBtn;
@property (nonatomic,strong) UIButton *postBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _getBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 100, 85, 30)];
    [_getBtn setTitle:@"testGet" forState:UIControlStateNormal];
    [_getBtn addTarget:self action:@selector(testGet) forControlEvents:UIControlEventTouchUpInside];
    _getBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_getBtn];
    
    _postBtn = [[UIButton alloc]initWithFrame:CGRectMake(220, 100, 85, 30)];
    [_postBtn setTitle:@"testPost" forState:UIControlStateNormal];
    [_postBtn addTarget:self action:@selector(testPost) forControlEvents:UIControlEventTouchUpInside];
    _postBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_postBtn];
    
    
    
}

- (void)testGet{
    LYWebClientInstance.endPoint = [NSURL URLWithString:@"https://api-bs.gomeplus.com"];
    [LYWebRequest(Module1Api) getGroupHomePageInfoWithSuceessBlock:^(NSArray *result, NSURLResponse *response) {
        NSLog(@"LYWebRequest Suceess");
    } failBlock:^(NSString *errorMessage, NSURLResponse *response, NSError *error) {
        NSLog(@"LYWebRequest fail");
    }];
    
    //    [LYWebRequestSpecial(Module1Api,LYPublicParamsInPath,[LYGomePlusPublicParams oldPubicParams]) getGroupHomePageInfoWithSuceessBlock:^(NSArray *result, NSURLResponse *response) {
    //        NSLog(@"LYWebRequest Suceess");
    //    } failBlock:^(NSString *errorMessage, NSURLResponse *response, NSError *error) {
    //        NSLog(@"LYWebRequest fail");
    //    }];
    
}

- (void)testPost{
    NSNumber *temp1 =  [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
    NSString *passWord = [NSString stringWithFormat:@"%@|%@",@"gome1234567",temp1];
    NSString *temp = [GGSafeHelper aesAndBase64:passWord];
    
    NSURLSessionDataTask *task = [LYWebRequestSpecial(Module1Api,LYPublicParamsInPath,[LYDemoPublicParams oldPubicParams]) loginV1:@"18001211728" passWord:temp suceessBlock:^(NSString *result, NSURLResponse *response) {
        NSLog(@"LYWebRequest Suceess");
    } failBlock:^(NSString *errorMessage, NSURLResponse *response, NSError *error) {
        NSLog(@"LYWebRequest fail");
    }];
    [task cancel];

}

- (void)testUpload{
}

- (void)testDownLoad{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
