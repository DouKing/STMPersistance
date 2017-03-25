//
//  STMPersistanceTests.m
//  STMPersistanceTests
//
//  Created by iosci on 2017/3/21.
//  Copyright © 2017年 secoo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "STMObject.h"

static NSString * const kSTMStudent = @"Student";
static NSString * const kSTMBook = @"Book";

@protocol BookRecord;

@protocol Student <STMRecord>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) id<BookRecord> book;

@end

@protocol BookRecord <STMRecord>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *price;

@end


@interface STMPersistanceTests : XCTestCase


@end

@implementation STMPersistanceTests

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testExample {
  STMObject<id<Student>> *xiaoming = [[STMObject alloc] initWithClassName:kSTMStudent];
  [xiaoming.record setName:@"小明"];
  [xiaoming.record setAge:@10];
  [xiaoming.record setScore:@80.0];
  
  STMObject<id<BookRecord>> *book1 = [[STMObject alloc] initWithClassName:kSTMBook];
  [book1.record setName:@"Chinese"];
  [book1.record setPrice:@66];
  
  [xiaoming.record setBook:book1.record];
  NSLog(@"%@", xiaoming);
}

- (void)testSave {
  STMObject<id<Student>> *xiaozhang = [[STMObject alloc] initWithClassName:kSTMStudent];
  [xiaozhang.record setName:@"小张"];
  [xiaozhang.record setAge:@11];
  [xiaozhang.record setScore:@88];
  
  STMObject<id<BookRecord>> *book2 = [[STMObject alloc] initWithClassName:kSTMBook];
  [book2.record setName:@"English"];
  [book2.record setPrice:@60.0];
  
  [xiaozhang.record setBook:book2.record];
  [xiaozhang saveRecord];
}

- (void)testFetch {
  NSArray<STMObject *> *all = [STMObject fetchAllFrom:kSTMStudent];
  NSLog(@"====================all");
  __block NSString *objId = nil;
  [all enumerateObjectsUsingBlock:^(STMObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSLog(@"%@", [obj.record jsonDictionary]);
    objId = obj.objectId;
  }];
  NSLog(@"====================all");
  
  STMObject<id<Student>> *z = [STMObject fetchWithObjectId:objId from:kSTMStudent];
  NSLog(@"fetch objId:\n%@", z);
}

- (void)testZZZZDelete {
  NSLog(@"count=========before> %lu", (unsigned long)[STMObject totalCount:kSTMStudent]);
  [STMObject deleteAllFrom:kSTMStudent];
  NSLog(@"count==========after> %lu", (unsigned long)[STMObject totalCount:kSTMStudent]);
}

- (void)testPerformanceExample {
  // This is an example of a performance test case.
  [self measureBlock:^{
    // Put the code you want to measure the time of here.
  }];
}

@end
