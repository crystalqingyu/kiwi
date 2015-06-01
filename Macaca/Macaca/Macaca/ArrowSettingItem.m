//
//  ArrowSettingItem.m
//  ItcastLottery
//
//  Created by Julie on 14/11/17.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "ArrowSettingItem.h"

@implementation ArrowSettingItem

- (instancetype)initWithIcon: (NSString*)icon text: (NSString*)text desClass: (Class)desClass {
    self.icon = icon;
    self.text = text;
    self.desClass = desClass;
    return self;
}

+ (instancetype)settingItemWithIcon: (NSString*)icon text: (NSString*)text desClass: (Class)desClass {
    return [[ArrowSettingItem alloc] initWithIcon:icon text:text desClass:desClass];
}


@end
