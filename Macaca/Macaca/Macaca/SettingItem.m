//
//  SettingItem.m
//  ItcastLottery
//
//  Created by Julie on 14/11/17.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "SettingItem.h"

@implementation SettingItem

- (instancetype)initWithIcon: (NSString*)icon text: (NSString*)text {
    self.icon = icon;
    self.text = text;
    return self;
}

+ (instancetype)settingItemWithIcon: (NSString*)icon text: (NSString*)text {
    return [[self alloc] initWithIcon:icon text:text];
}

- (instancetype)initWithIcon:(NSString *)icon text:(NSString *)text detailText:(NSString *)detailText {
    self.icon = icon;
    self.text = text;
    self.detailText = detailText;
    return self;
}

+ (instancetype)settingItemWithIcon:(NSString *)icon text:(NSString *)text detailText:(NSString *)detailText {
    return [[self alloc] initWithIcon:icon text:text detailText:detailText];
}

@end
