//
//  MaTabbarController.m
//  Macaca
//
//  Created by Julie on 14/12/9.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "MaTabbarController.h"
#import "ActRecordViewController.h"
#import "MaNavigationController.h"
#import "GuideViewController.h"

@interface MaTabbarController ()

@end

@implementation MaTabbarController

-(void)viewWillAppear:(BOOL)animated
{
    // 显示新手指引
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])  {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
        self.guideVc=[self.storyboard instantiateViewControllerWithIdentifier:@"guideViewController"];
        UIView* guideView = self.guideVc.view;
        CGRect switchViewFrame=guideView.frame; //得到frame
        switchViewFrame.origin.y=0;            //将推入视图的y值设置为0，目的是防止出现视图加载下移的情况
        guideView.frame=switchViewFrame;
        [self.view insertSubview:guideView aboveSubview:self.view];
        //[guideView addSubview:self.view];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 手动设置tabbarItem的选中图片
    int count = self.tabBar.items.count;
    for (int i = 0; i<count; i++) {
        UITabBarItem* item = [self.tabBar.items objectAtIndex:i];
        item.selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon%ds",i]];
    }
    self.tabBar.tintColor = [UIColor colorWithRed:226.0/255.0 green:42.0/255.0 blue:52.0/255.0 alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)initialize {
    // 设置tabBar主题：背景、标题
    UITabBar* bar = [UITabBar appearance];
    [bar setBarStyle:UIBarStyleDefault];
    [bar setTranslucent:YES];
//    [bar setBarTintColor:[UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1]];// 想设置tintColor必须先设置style，要不不能设置
//    // 设置tabbarItem主题：文字、背景
//    UITabBarItem* item = [UITabBarItem appearance];
//    NSMutableDictionary* itemAttrs = [NSMutableDictionary dictionary];
////    itemAttrs[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
//    itemAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:11];
//    [item setTitleTextAttributes:itemAttrs forState:UIControlStateNormal];
    
//    // 选中Item状态设置
//    NSMutableDictionary* itemSelectedAttrs = [NSMutableDictionary dictionary];
//    itemSelectedAttrs[NSForegroundColorAttributeName] = [UIColor blueColor];
//    [item setTitleTextAttributes:itemSelectedAttrs forState:UIControlStateSelected];
    
}

//// 选中一个tabBarItem的操作
//- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
//    // 自动退回到rootController，且无动画
//    if ([self.selectedViewController isKindOfClass:[MaNavigationController class]]) {
//        MaNavigationController* navController = (MaNavigationController*)self.selectedViewController;
//        [navController popToRootViewControllerAnimated:NO];
//    }
//}


@end
