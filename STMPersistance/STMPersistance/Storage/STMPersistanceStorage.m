//
//  STMPersistanceStorage.m
//  STMPersistance
//
//  Created by iosci on 2017/3/22.
//  Copyright © 2017年 secoo. All rights reserved.
//

#import "STMPersistanceStorage.h"
#import <FMDB/FMDB.h>

#define CHEAK_TABLE(tableName) NSAssert((tableName.length && [tableName rangeOfString:@" "].location == NSNotFound),@"表名无效")

static NSString * const kSTMCreatTableSQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
objectId TEXT NOT NULL, \
json TEXT NOT NULL, \
PRIMARY KEY(objectId)) \
";
static NSString *const kSTMUpdateItemSQL  = @"REPLACE INTO %@ (objectId, json) values (?, ?)";
static NSString *const kSTMQueryItemSQL   = @"SELECT json from %@ where objectId = ? Limit 1";
static NSString *const kSTMClearAllSQL    = @"DELETE from %@";
static NSString *const kSTMDeleteItemSQL  = @"DELETE from %@ where objectId = ?";
static NSString *const kSTMDropTableSQL   = @" DROP TABLE '%@' ";
static NSString *const kSTMSelectAllSQL   = @"SELECT * from %@";
static NSString *const kSTMCountAllSQL    = @"SELECT count(*) as num from %@";

@interface STMPersistanceStorage ()

@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic, strong) NSString *databasePath;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation STMPersistanceStorage

- (instancetype)initWithDatabsaeName:(NSString *)dbName {
  self = [super init];
  if (self) {
    _databaseName = dbName;
  }
  return self;
}

- (void)close {
  [_dbQueue close];
  _dbQueue = nil;
}

#pragma mark - setter & getter

- (FMDatabaseQueue *)dbQueue {
  if (!_dbQueue) {
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.databasePath];
    NSLog(@"path:\n%@", self.databasePath);
  }
  return _dbQueue;
}

- (NSString *)databaseName {
  if (!_databaseName) {
    _databaseName = @"STMDatabase.sqlite";
  }
  return _databaseName;
}

- (NSString *)databasePath {
  if (!_databasePath) {
    _databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                     stringByAppendingPathComponent:self.databaseName];
  }
  return _databasePath;
}

@end

@implementation STMPersistanceStorage (Table)

- (void)createTable:(NSString *)tableName {
  CHEAK_TABLE(tableName);
  NSString * sql = [NSString stringWithFormat:kSTMCreatTableSQL, tableName];
  __block BOOL result;
  [self.dbQueue inDatabase:^(FMDatabase *db) {
    result = [db executeUpdate:sql];
  }];
  if (!result) {
    NSLog(@"ERROR, failed to create table: %@", tableName);
  }
}

- (BOOL)existsTable:(NSString *)tableName {
  CHEAK_TABLE(tableName);
  __block BOOL result;
  [self.dbQueue inDatabase:^(FMDatabase *db) {
    result = [db tableExists:tableName];
  }];
  if (!result) {
    NSLog(@"ERROR, table: %@ not exists in current DB", tableName);
  }
  return result;
}

- (void)clearTable:(NSString *)tableName {
  CHEAK_TABLE(tableName);
  NSString * sql = [NSString stringWithFormat:kSTMClearAllSQL, tableName];
  __block BOOL result;
  [self.dbQueue inDatabase:^(FMDatabase *db) {
    result = [db executeUpdate:sql];
  }];
  if (!result) {
    NSLog(@"ERROR, failed to clear table: %@", tableName);
  }
}

- (void)dropTable:(NSString *)tableName {
  CHEAK_TABLE(tableName);
  NSString * sql = [NSString stringWithFormat:kSTMDropTableSQL, tableName];
  __block BOOL result;
  [self.dbQueue inDatabase:^(FMDatabase *db) {
    result = [db executeUpdate:sql];
  }];
  if (!result) {
    NSLog(@"ERROR, failed to drop table: %@", tableName);
  }
}

@end

@implementation STMPersistanceStorage (Operate)

- (void)updateObject:(id)obj withObjectId:(NSString *)objectId inTable:(NSString *)tableName {
  CHEAK_TABLE(tableName);
  NSString *jsonString = @"";
  if ([obj isKindOfClass:[NSString class]]) {
    jsonString = obj;
  } else if ([NSJSONSerialization isValidJSONObject:obj]) {
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
    jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  } else {
    jsonString = [obj description];
  }
  NSString *sql = [NSString stringWithFormat:kSTMUpdateItemSQL, tableName];
  __block BOOL result;
  [self.dbQueue inDatabase:^(FMDatabase *db) {
    result = [db executeUpdate:sql, objectId, jsonString];
  }];
  if (!result) {
    NSLog(@"ERROR, failed to insert/replace into table: %@", tableName);
  }
}

- (NSArray<NSString *> *)fetchAllTextObjectFromTable:(NSString *)tableName {
  CHEAK_TABLE(tableName);
  NSString *sql = [NSString stringWithFormat:kSTMSelectAllSQL, tableName];
  NSMutableArray<NSString *> *result = [NSMutableArray array];
  [self.dbQueue inDatabase:^(FMDatabase *db) {
    FMResultSet * rs = [db executeQuery:sql];
    while ([rs next]) {
      [result addObject:[rs stringForColumn:@"json"]];
    }
    [rs close];
  }];
  return result;
}

- (NSArray *)fetchAllJSONObjectFromTable:(NSString *)tableName {
  CHEAK_TABLE(tableName);
  NSString *sql = [NSString stringWithFormat:kSTMSelectAllSQL, tableName];
  NSMutableArray *result = [NSMutableArray array];
  [self.dbQueue inDatabase:^(FMDatabase *db) {
    FMResultSet * rs = [db executeQuery:sql];
    while ([rs next]) {
      NSString *text = [rs stringForColumn:@"json"];
      NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
      id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
      if (obj) {
        [result addObject:obj];
      } else {
        NSLog(@"ERROR: failed to get json when fetch json objects:(%@)", [rs stringForColumn:@"objectId"]);
      }
    }
    [rs close];
  }];
  return result;
}

- (NSString *)fetchTextObjectWithObjectId:(NSString *)objectId fromTable:(NSString *)tableName {
  CHEAK_TABLE(tableName);
  NSString *sql = [NSString stringWithFormat:kSTMQueryItemSQL, tableName];
  __block NSString *text = nil;
  [self.dbQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *rs = [db executeQuery:sql, objectId];
    if ([rs next]) {
      text = [rs stringForColumn:@"json"];
    }
    [rs close];
  }];
  return text;
}

- (id)fetchJSONObjectWithObjectId:(NSString *)objectId fromTable:(NSString *)tableName {
  NSString *json = [self fetchTextObjectWithObjectId:objectId fromTable:tableName];
  if (!json) {
    return nil;
  }
  NSError *error = nil;
  id result = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                              options:NSJSONReadingAllowFragments
                                                error:&error];
  if (error) {
    NSLog(@"ERROR, faild to prase to json");
    return json;
  }
  return result;
}

- (void)deleteObjectWithObjectId:(NSString *)objectId fromTable:(NSString *)tableName {
  CHEAK_TABLE(tableName);
  NSString *sql = [NSString stringWithFormat:kSTMDeleteItemSQL, tableName];
  __block BOOL result;
  [self.dbQueue inDatabase:^(FMDatabase *db) {
    result = [db executeUpdate:sql, objectId];
  }];
  if (!result) {
    NSLog(@"ERROR, failed to delete item from table: %@", tableName);
  }
}

- (NSUInteger)getCountFromTable:(NSString *)tableName {
  CHEAK_TABLE(tableName);
  NSString *sql = [NSString stringWithFormat:kSTMCountAllSQL, tableName];
  __block NSUInteger num = 0;
  [self.dbQueue inDatabase:^(FMDatabase *db) {
    FMResultSet * rs = [db executeQuery:sql];
    if ([rs next]) {
      num = [rs unsignedLongLongIntForColumn:@"num"];
    }
    [rs close];
  }];
  return num;
}

@end
