//
//  STMPersistanceStorage.h
//  STMPersistance
//
//  Created by iosci on 2017/3/22.
//  Copyright © 2017年 secoo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface STMPersistanceStorage : NSObject

- (instancetype)initWithDatabsaeName:(NSString *)dbName;
- (void)close;

@end

@interface STMPersistanceStorage (Table)
- (void)createTable:(NSString *)tableName;
- (BOOL)existsTable:(NSString *)tableName;
- (void)clearTable:(NSString *)tableName;
- (void)dropTable:(NSString *)tableName;
@end

@interface STMPersistanceStorage (Operate)

- (void)updateObject:(id)obj withObjectId:(NSString *)objectId inTable:(NSString *)tableName;
- (NSArray<NSString *> *)fetchAllTextObjectFromTable:(NSString *)tableName;
- (NSArray *)fetchAllJSONObjectFromTable:(NSString *)tableName;
- (nullable NSString *)fetchTextObjectWithObjectId:(NSString *)objectId fromTable:(NSString *)tableName;
- (nullable id)fetchJSONObjectWithObjectId:(NSString *)objectId fromTable:(NSString *)tableName;
- (void)deleteObjectWithObjectId:(NSString *)objectId fromTable:(NSString *)tableName;
- (NSUInteger)getCountFromTable:(NSString *)tableName;

@end


NS_ASSUME_NONNULL_END
