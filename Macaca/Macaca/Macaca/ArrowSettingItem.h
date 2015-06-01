//
//  ArrowSettingItem.h
//  ItcastLottery
//
//  Created by Julie on 14/11/17.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "SettingItem.h"

@interface ArrowSettingItem : SettingItem

@property (nonatomic, strong) Class desClass;

// 初始化item对象
- (instancetype)initWithIcon: (NSString*)icon text: (NSString*)text desClass: (Class)desClass;
+ (instancetype)settingItemWithIcon: (NSString*)icon text: (NSString*)text desClass: (Class)desClass;

@end
