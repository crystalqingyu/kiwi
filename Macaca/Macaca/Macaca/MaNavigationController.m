//
//  MaNavigationController.m
//  Macaca
//
//  Created by Julie on 14/12/9.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "MaNavigationController.h"

@interface MaNavigationController ()

@end

@implementation MaNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)initialize {
    // 设置导航栏主题：背景、标题
    UINavigationBar* bar = [UINavigationBar appearance];
    [bar setBarStyle:UIBarStyleBlackTranslucent];
    bar.tintColor = [UIColor colorWithRed:226.0/255 green:42.0/255 blue:52.0/255 alpha:1];
//    [bar setBackgroundColor:[UIColor colorWithRed:88.0/255.0 green:187.0/255.0 blue:136.0/255.0 alpha:1]];
//    NSString *bgName = nil;
//    if (iOS7) { // 至少是iOS 7.0
//        bgName = @"NavBar64";
//        bar.tintColor = [UIColor whiteColor];
//    } else { // 非iOS7
//        bgName = @"NavBar";
//    }
    NSMutableDictionary* barAttrs = [NSMutableDictionary dictionary];
    barAttrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:255.0/255 green:253.0/255 blue:198.0/255 alpha:1];
    barAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:17];
    [bar setTitleTextAttributes:barAttrs];
    // 设置BarButtonItem主题：文字、背景
    UIBarButtonItem* item = [UIBarButtonItem appearance];
    NSMutableDictionary* itemAttrs = [NSMutableDictionary dictionary];
    itemAttrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:226.0/255 green:42.0/255 blue:52.0/255 alpha:1];
    itemAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:14];
    [item setTitleTextAttributes:itemAttrs forState:UIControlStateNormal];
}


@end
