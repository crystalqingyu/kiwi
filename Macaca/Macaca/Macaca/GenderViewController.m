//
//  GenderViewController.m
//  Macaca
//
//  Created by Julie on 14/12/12.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "GenderViewController.h"

@interface GenderViewController ()

@end

@implementation GenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"性别";
    
    // 添加segmentControl
//    UISegmentedControl* genderControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height*0.5, self.view.frame.size.width-2*10, 70)];
    UISegmentedControl* genderControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
    [genderControl insertSegmentWithTitle: @"男" atIndex: 0 animated: NO ];
    [genderControl insertSegmentWithTitle: @"女" atIndex: 1 animated: NO ];
    [self.view addSubview:genderControl];
    // 添加constraints
    [genderControl setTranslatesAutoresizingMaskIntoConstraints:NO];//别忘了！！！
     NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:genderControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.00f];
    [self.view addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:genderControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.00f];
    [self.view addConstraint:constraint];
    NSDictionary* views = NSDictionaryOfVariableBindings(genderControl);
    NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[genderControl(>=250)]-|" options:0 metrics:nil views:views];
    [self.view addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=165)-[genderControl(>=150)]-(>=165)-|" options:0 metrics:nil views:views];
    [self.view addConstraints:constraints];
    
    // 读取文件初始化设置
    NSString* initGender = [[NSUserDefaults standardUserDefaults] objectForKey:@"gender"];
    [genderControl setSelectedSegmentIndex:[initGender intValue]];
    //[genderControl setTintColor:[UIColor colorWithRed:255.0/255 green:239.0/255 blue:219.0/255 alpha:1]];
    // 设置title属性(normal selected)
    NSMutableDictionary* genderAttrs = [NSMutableDictionary dictionary];
    genderAttrs[NSForegroundColorAttributeName] = [UIColor redColor];
    genderAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:20];
    [genderControl setTitleTextAttributes:genderAttrs forState:UIControlStateSelected];
    NSMutableDictionary* barAttrs = [NSMutableDictionary dictionary];
    barAttrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:139.0/255 green:178.0/255 blue:38.0/255 alpha:1];
    barAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:20];
    [genderControl setTitleTextAttributes:barAttrs forState:UIControlStateNormal];
    // 监听性别选择改变
    [genderControl addTarget:self action:@selector(clickSeg:) forControlEvents:UIControlEventValueChanged];
    
//    // 自定义tabbar，并添加，注意与自定义navigationbar区别
//    UITabBar* genderBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 40)];
//    UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"男" image:nil tag:0];
//    [genderBar setItems:@[item]];
//    [self.view addSubview:genderBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickSeg :(UISegmentedControl*)segControl {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    // 存储数据
    [defaults setObject:[NSString stringWithFormat:@"%d",segControl.selectedSegmentIndex] forKey:@"gender"];
    // 立刻同步
    [defaults synchronize];
}

@end
