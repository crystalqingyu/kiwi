//
//  VersionIntroductionViewController.m
//  Macaca
//
//  Created by Julie on 15/3/8.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "VersionIntroductionViewController.h"

@interface VersionIntroductionViewController ()

@end

@implementation VersionIntroductionViewController

// 手动隐藏tabbar，注意要再init中实现
- (instancetype)init {
    if ([super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"功能介绍";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
