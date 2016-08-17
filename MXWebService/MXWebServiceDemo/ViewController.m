//
//  ViewController.m
//  MXWebServiceDemo
//
//  Created by lly on 16/8/16.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import "ViewController.h"
#import "ModuleTestApi.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MXWebClientInstance.endPoint = [NSURL URLWithString:@"https://api.julyedu.com"];
    [MXWebRequest(Module1Api) login:@"576061110@qq.com" passWord:@"1357qwer" suceessBlock:^(NSString *result, NSURLResponse *response) {
        NSLog(@"MXWebRequest Suceess");
    } failBlock:^(NSString *errorMessage, NSURLResponse *response, NSError *error) {
        NSLog(@"MXWebRequest fail");
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
