//
//  GroupSetting.h
//  ItcastLottery
//
//  Created by Julie on 14/11/17.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupSetting : NSObject

@property (nonatomic, copy) NSString* title;

@property (nonatomic, copy) NSString* footer;

// item数组
@property (nonatomic, strong) NSArray* settingGroup;

@end
