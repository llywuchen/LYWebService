//
//  MXEngineTests.m
//  MXEngineTests
//
//  Created by lly on 16/5/26.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MXWebService.h"
#import "MXTextApi.h"
#import "ModuleTestApi.h"
#import "MXWebClient.h"
#import "MXTextModel.h"

@import Nimble;
@import Quick;

@interface MXEngineTests : XCTestCase

@end

@implementation MXEngineTests

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
    MXWebClientInstance.endPoint = [NSURL URLWithString:@"https://api.julyedu.com"];
    [MXWebRequest(Module1Api) getInfoWithSuceessBlock:^(NSArray *result, NSURLResponse *response) {
        NSLog(@"MXWebRequest Suceess");
    } failBlock:^(NSString *errorMessage, NSURLResponse *response, NSError *error) {
        NSLog(@"MXWebRequest fail");
    }];
    //
    ////    return;
    //    MXWebClientInstance.endPoint = [NSURL URLWithString:@"https://api-bs.gomeplus.com"];//]@"https://api.julyedu.com"];
    //    [MXWebRequest(Module1Api) getGroupHomePageInfoWithSuceessBlock:^(NSArray *result, NSURLResponse *response) {
    //        NSLog(@"MXWebRequest Suceess");
    //        XCTAssertNil(result);
    //        XCTAssertNil(response);
    //    }];
    //
    //        XCTAssertNil(error);
    //        XCTAssertNil(errorMessage);
    //        XCTAssertNil(response);
    sleep(5);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


@end
