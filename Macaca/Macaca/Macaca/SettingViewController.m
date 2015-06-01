//
//  SettingViewController.m
//  Macaca
//
//  Created by Julie on 14/12/12.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "SettingViewController.h"
#import "GroupSetting.h"
#import "SettingItem.h"
#import "ArrowSettingItem.h"
#import "PersonDataViewController.h"
#import "TestViewController.h"
#import "AboutViewController.h"
#import "GuideViewController.h"
#import "VersionIntroductionViewController.h"

@interface SettingViewController ()

@property (nonatomic, copy) NSString* trackViewUrl; //打开”检查新版本“的链接

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加第0组数据
    [self setUpGroup0];
    // 添加第1组数据
    [self setUpGroup1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpGroup0 {
    SettingItem* item0 = [ArrowSettingItem settingItemWithIcon:@"profile" text:@"个人资料" desClass:[PersonDataViewController class]];
    GroupSetting* group = [[GroupSetting alloc] init];
    group.footer = @"通过设置个人资料，可以根据你的基本信息提高运动记录数据和基础代谢值的准确性";
    //group.title = @"";
    group.settingGroup = @[item0];
    [self.data addObject:group];
}

- (void)setUpGroup1 {
    SettingItem* item0= [ArrowSettingItem settingItemWithIcon:@"guide" text:@"新手指引" desClass:[GuideViewController class]];
    SettingItem* item1= [ArrowSettingItem settingItemWithIcon:@"pingfen" text:@"给猕猴桃评分" desClass:nil];
    item1.option = ^{
        NSString* appid = @"966621372";
        NSString* str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appid];
        NSURL* url = [NSURL URLWithString:str];
        [[UIApplication sharedApplication] openURL:url];
    };
    SettingItem* item2 = [ArrowSettingItem settingItemWithIcon:@"about" text:@"关于猕猴桃" desClass:[AboutViewController class]];
    GroupSetting* group = [[GroupSetting alloc] init];
    //group.footer = @"敬请期待";
    //group.title = @"根据个人情况与喜好设置";
    group.settingGroup = @[item0, item1, item2];
    [self.data addObject:group];
}

@end
