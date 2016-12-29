//
//  ViewController.m
//  LYWebServiceDemo
//
//  Created by lly on 16/8/16.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import "ViewController.h"
#import "LYTextApi.h"
#import "LYPublicParams.h"

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
    [LYWebRequest(LYTextApi) getInfo:@"my_appSecret" suceessBlock:^(NSArray *result, NSURLResponse *response) {
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
