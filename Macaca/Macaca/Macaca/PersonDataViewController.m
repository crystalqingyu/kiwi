//
//  PersonDataViewController.m
//  Macaca
//
//  Created by Julie on 14/12/12.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "PersonDataViewController.h"
#import "ArrowSettingItem.h"
#import "GroupSetting.h"
#import "GenderViewController.h"
#import "BirthDateViewController.h"
#import "HeightViewController.h"
#import "WeightViewController.h"


@interface PersonDataViewController ()

@end

@implementation PersonDataViewController

// 手动隐藏tabbar，注意要再init中实现
- (instancetype)init {
    if ([super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人资料";
    // 添加第0组数据
    [self setUpGroup0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpGroup0 {
    SettingItem* item0 = [ArrowSettingItem settingItemWithIcon:@"gender" text:@"性别" desClass:[GenderViewController class]];
    SettingItem* item1= [ArrowSettingItem settingItemWithIcon:@"birthday" text:@"出生日期" desClass:[BirthDateViewController class]];
    SettingItem* item2 = [ArrowSettingItem settingItemWithIcon:@"height" text:@"身高" desClass:[HeightViewController class]];
    SettingItem* item3 = [ArrowSettingItem settingItemWithIcon:@"weight.png" text:@"体重" desClass:[WeightViewController class]];
    GroupSetting* group = [[GroupSetting alloc] init];
    //group.footer = @"敬请期待";
    //group.title = @"根据个人情况与喜好设置";
    group.settingGroup = @[item0, item1, item2, item3];
    [self.data addObject:group];
}
@end
