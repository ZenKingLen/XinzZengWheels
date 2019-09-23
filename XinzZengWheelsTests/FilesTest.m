//
//  FilesTest.m
//  XinzZengWheelsTests
//
//  Created by 曾杏枝 on 2019/7/9.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XZhFiles.h"

@interface FilesTest : XCTestCase

@end

@implementation FilesTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test_uniformtCaseFiles {
    NSString *document = [[NSBundle mainBundle] pathForResource:@"jpg_images.bundle" ofType:nil];
    NSArray *jpgs = XZhFiles.uniformtCaseFiles(document, @"jpg");
    XCTAssert(jpgs.count == 1, "fail");
    jpgs = XZhFiles.uniformtCaseFiles(document, @"png");
    XCTAssert(jpgs.count == 0, "fail");
}

- (void)test_uniformtNoCaseFiles {
    NSString *document = [[NSBundle mainBundle] pathForResource:@"jpg_images.bundle" ofType:nil];
    NSArray *jpgs = XZhFiles.uniformtNoCaseFiles(document, @"jpg");
    XCTAssert(jpgs.count == 3, "fail");
    jpgs = XZhFiles.uniformtNoCaseFiles(document, @"png");
    XCTAssert(jpgs.count == 0, "fail");
}

- (void)test_uniformtFiles {
    NSString *document = [[NSBundle mainBundle] pathForResource:@"jpg_images.bundle" ofType:nil];
    NSArray *jpgs = XZhFiles.uniformtFiles(document, @"jpg", YES);
    XCTAssert(jpgs.count == 1, "fail");
    jpgs = XZhFiles.uniformtFiles(document, @"jpg", NO);
    XCTAssert(jpgs.count == 3, "fail");
    jpgs = XZhFiles.uniformtFiles(document, @"png", YES);
    XCTAssert(jpgs.count == 0, "fail");
    jpgs = XZhFiles.uniformtFiles(document, @"png", NO);
    XCTAssert(jpgs.count == 0, "fail");
}

- (void)test_documentFiles {
    NSString *document = [[NSBundle mainBundle] pathForResource:@"jpg_images.bundle" ofType:nil];
    NSArray *jpgs = XZhFiles.documentFiles(document);
    XCTAssert(jpgs.count == 3, "fail");
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
