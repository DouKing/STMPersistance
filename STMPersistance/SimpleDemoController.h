//
//  SimpleDemoController.h
//  STMPersistance
//
//  Created by iosci on 2017/3/25.
//  Copyright © 2017年 secoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMObject.h"

@protocol Meeting <STMRecord>

@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *place;

@end


@interface SimpleDemoController : UITableViewController

@end

@interface SimpleCell : UITableViewCell

@property (nonatomic, strong) STMObject<id<Meeting>> *meeting;

@end
