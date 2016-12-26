//
//  LYWebServiceTests.m
//  LYWebServiceTests
//
//  Created by lly on 16/5/26.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LYWebService.h"
#import "LYTextApi.h"
#import "ModuleTestApi.h"
#import "LYWebClient.h"
#import "LYTextModel.h"

//@import Nimble;
//@import Quick;

@interface LYWebServiceTests : XCTestCase

@end

@implementation LYWebServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    //    LYWebClientInstance.endPoint = [NSURL URLWithString:@"https://api.julyedu.com"];
    //    [LYWebRequest(Module1Api) getInfoWithSuceessBlock:^(NSArray *result, NSURLResponse *response) {
    //        NSLog(@"LYWebRequest Suceess");
    //    } failBlock:^(NSString *errorMessage, NSURLResponse *response, NSError *error) {
    //        NSLog(@"LYWebRequest fail");
    //    }];
    
    //
    ////    return;
    //    LYWebClientInstance.endPoint = [NSURL URLWithString:@"https://api-bs.gomeplus.com"];//]@"https://api.julyedu.com"];
    //    [LYWebRequest(Module1Api) getGroupHomePageInfoWithSuceessBlock:^(NSArray *result, NSURLResponse *response) {
    //        NSLog(@"LYWebRequest Suceess");
    //        XCTAssertNil(result);
    //        XCTAssertNil(response);
    //    }];
    //
    //        XCTAssertNil(error);
    //        XCTAssertNil(errorMessage);
    //        XCTAssertNil(response);
    //    sleep(5);
}


- (void)testPost {
    LYWebClientInstance.endPoint = [NSURL URLWithString:@"https://api.julyedu.com"];
    [LYWebRequest(Module1Api) login:@"576061110@qq.com" passWord:@"1357qwer" suceessBlock:^(NSString *result, NSURLResponse *response) {
        NSLog(@"LYWebRequest Suceess");
    } failBlock:^(NSString *errorMessage, NSURLResponse *response, NSError *error) {
        NSLog(@"LYWebRequest fail");
    }];
    sleep(25);
}


- (void)testUpload{
    
}

- (void)testDownload{
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


@end
