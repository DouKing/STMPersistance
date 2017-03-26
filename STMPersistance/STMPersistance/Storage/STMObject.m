//
//  STMTable.m
//  STMPersistance
//
//  Created by iosci on 2017/3/22.
//  Copyright © 2017年 secoo. All rights reserved.
//

#import "STMObject.h"
#import "STMPersistanceStorage.h"

@implementation STMPersistanceStorage (STMObject)
+ (instancetype)sharedInstance {
  static id _sharedInstance = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[self alloc] init];
  });
  return _sharedInstance;
}
@end

@interface NSString (MD5)
- (NSString *)_stringToMD5;
@end

@protocol _STMPrivateRecord <STMRecord>
@property (nonatomic, strong) NSString *objectId;
@end

@interface STMObject ()

@property (nonatomic, strong) id<_STMPrivateRecord> record;

@end

@implementation STMObject

- (instancetype)initWithClassName:(NSString *)className {
  return [self initWithClassName:className record:nil];
}

- (instancetype)initWithClassName:(NSString *)className record:(id)record {
  NSAssert((className.length && [className rangeOfString:@" "].location == NSNotFound),
           @"表名格式不正确");
  self = [super init];
  if (self) {
    _className = [className copy];
    if (record) {
      _record = record;
    } else {
      [self _creatRecord];
    }
    [[STMPersistanceStorage sharedInstance] createTable:className];
  }
  return self;
}

#pragma mark - override

- (NSString *)description {
  NSDictionary *dic = [self.record jsonDictionary];
  NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
  return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - Private

- (void)_creatRecord {
  _record = STMCreatRecord();
  int random = arc4random() % 10;
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd/HH:mm:ss/SSS/"];
  NSDate *date = [NSDate date];
  NSString *dateStr = [[formatter stringFromDate:date] stringByAppendingFormat:@"%d", random];
  [_record setObjectId:[dateStr _stringToMD5]];
}

#pragma mark - setter & getter

- (NSString *)objectId {
  return [self.record objectId];
}

@end

@implementation STMObject (Storage)

+ (STMObject<id> *)fetchWithObjectId:(NSString *)objectId from:(NSString *)className {
  id obj = [[STMPersistanceStorage sharedInstance] fetchJSONObjectWithObjectId:objectId fromTable:className];
  if (!obj || ![obj isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  return [[STMObject alloc] initWithClassName:className record:STMCreatRecordWithDictionary(obj)];
}

+ (NSArray<STMObject<id> *> *)fetchAllFrom:(NSString *)className {
  NSArray *objs = [[STMPersistanceStorage sharedInstance] fetchAllJSONObjectFromTable:className];
  NSMutableArray<STMObject *> *result = [NSMutableArray arrayWithCapacity:objs.count];
  [objs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj isKindOfClass:[NSDictionary class]]) {
      [result addObject:[[STMObject alloc] initWithClassName:className record:STMCreatRecordWithDictionary(obj)]];
    }
  }];
  return result;
}

+ (void)deleteAllFrom:(NSString *)className {
  [[STMPersistanceStorage sharedInstance] clearTable:className];
}

+ (NSUInteger)totalCount:(NSString *)className {
  return [[STMPersistanceStorage sharedInstance] getCountFromTable:className];
}

+ (void)asyncFetchWithObjectId:(NSString *)objectId from:(NSString *)className completion:(void (^)(STMObject<id> *))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    if (completion) {
      completion([self fetchWithObjectId:objectId from:className]);
    }
  });
}

+ (void)asyncFetchAllFrom:(NSString *)className completion:(void (^)(NSArray<STMObject<id> *> *))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    if (completion) {
      completion([self fetchAllFrom:className]);
    }
  });
}

- (void)saveRecord {
  [[STMPersistanceStorage sharedInstance] updateObject:[self.record jsonDictionary]
                                          withObjectId:self.objectId
                                               inTable:self.className];
}

- (void)asyncSaveRecord:(void (^)())completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [weakSelf saveRecord];
    if (completion) {
      completion();
    }
  });
}

- (void)deleteRecord {
  [[STMPersistanceStorage sharedInstance] deleteObjectWithObjectId:self.objectId fromTable:self.className];
}

- (void)asyncDeleteRecord:(void (^)())completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [weakSelf deleteRecord];
    if (completion) {
      completion();
    }
  });
}

@end

#pragma mark -
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (NSString *)_stringToMD5 {
  if (!self.length) {
    return nil;
  }
  const char *value = [self UTF8String];
  
  unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
  CC_MD5(value, (unsigned)strlen(value), outputBuffer);
  
  NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
    [outputString appendFormat:@"%02x", outputBuffer[count]];
  }
  return outputString;
}

@end

