//
//  SettingItem.h
//  ItcastLottery
//
//  Created by Julie on 14/11/17.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SettingItemOption)();

@interface SettingItem : NSObject

@property (nonatomic, copy) NSString* icon;
@property (nonatomic, copy) NSString* text;
/*
 **点击cell有没有什么事情可做
 */
@property (nonatomic, copy) SettingItemOption option;
/*
 **关于里面detailText
 */
@property (nonatomic, copy) NSString* detailText;

// 初始化item对象的各种方法
- (instancetype)initWithIcon: (NSString*)icon text: (NSString*)text;
+ (instancetype)settingItemWithIcon: (NSString*)icon text: (NSString*)text;
- (instancetype)initWithIcon: (NSString*)icon text: (NSString*)text detailText: (NSString*)detailText;
+ (instancetype)settingItemWithIcon: (NSString*)icon text: (NSString*)text detailText: (NSString*)detailText;


@end
