//
//  STMTable.h
//  STMPersistance
//
//  Created by iosci on 2017/3/22.
//  Copyright © 2017年 secoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <STMRecord/STMRecord.h>

NS_ASSUME_NONNULL_BEGIN


@interface STMObject<RecordType> : NSObject

@property (nonatomic, copy, readonly) NSString *className;
@property (nonatomic, copy, readonly) NSString *objectId;
@property (nonatomic, strong, readonly) RecordType record;

- (instancetype)initWithClassName:(NSString *)className;
- (instancetype)initWithClassName:(NSString *)className record:(RecordType _Nullable)record;

@end

@interface STMObject<RecordType> (Storage)

+ (nullable STMObject<RecordType> *)fetchWithObjectId:(NSString *)objectId from:(NSString *)className;
+ (NSArray<STMObject<RecordType> *> *)fetchAllFrom:(NSString *)className;
+ (void)deleteAllFrom:(NSString *)className;
+ (NSUInteger)totalCount:(NSString *)className;

+ (void)asyncFetchAllFrom:(NSString *)className completion:(void (^ _Nullable)(NSArray *lists))completion;

- (void)saveRecord;
- (void)asyncSaveRecord:(void (^ _Nullable)())completion;

- (void)deleteRecord;

@end


NS_ASSUME_NONNULL_END
