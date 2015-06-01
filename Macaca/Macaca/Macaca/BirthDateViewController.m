//
//  BirthDateViewController.m
//  Macaca
//
//  Created by Julie on 14/12/12.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "BirthDateViewController.h"

@interface BirthDateViewController () 

@property (nonatomic, strong) UIDatePicker* datePicker;
@property (nonatomic, strong) NSDate* date;

@end

@implementation BirthDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"出生日期";
    // 添加选择器
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [self.view addSubview:_datePicker]; // 必须要先添加
    [_datePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_datePicker attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.00f];
    [self.view addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:_datePicker attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.00f];
    [self.view addConstraint:constraint];
    // 读取文件初始化设置_date、datePicker
    NSString* initBirthDateStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"birthdate"];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // 必须跟application里的一样
    NSDate *initBirthDate = [dateFormat dateFromString:initBirthDateStr];
    [_datePicker setDate:initBirthDate];
    [self clickPicker:_datePicker];
    // 监听选择器
    [_datePicker addTarget:self action:@selector(clickPicker:) forControlEvents:UIControlEventValueChanged];
    
//    // 添加对应lable显示选择日期
//    UILabel* dateLable = [[UILabel alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height*0.7, (self.view.frame.size.width-2*10)*0.5, 30)];
//    //dateLable.backgroundColor = [UIColor grayColor];
//    dateLable.layer.borderColor = [UIColor lightGrayColor].CGColor;// 边框颜色,要为CGColor
//    dateLable.layer.borderWidth = 1;// 边框宽度
//    dateLable.layer.cornerRadius = 10;  // lable圆角
//    [self.view addSubview:dateLable];
    
    // 添加button确定
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectZero];
    button.backgroundColor = [UIColor colorWithRed:255.0/255 green:251.0/255 blue:103.0/255 alpha:1];
    button.layer.borderWidth = 0.5;
    button.layer.cornerRadius = 10;
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:30.0/255 green:86.0/255 blue:186.0/255 alpha:1] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:button]; // 先添加！
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    constraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.00f];
    [self.view addConstraint:constraint];// 水平居中
    constraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.3f constant:0.00f];
    [self.view addConstraint:constraint]; // 宽度
    constraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_datePicker attribute:NSLayoutAttributeBottom multiplier:1.1f constant:0.00f];
    [self.view addConstraint:constraint]; // 顶端位置
    // 监听按钮
    [button addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 监听时间选择器
- (void)clickPicker: (UIDatePicker*)picker {
    self.date = picker.date;
}

// 监听确定按钮
- (void)submit {
    // 存储数据
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // 格式与application里面一样
    NSString *currentDateStr = [dateFormat stringFromDate:self.date];
    [defaults setObject:[NSString stringWithFormat:@"%@",currentDateStr] forKey:@"birthdate"];
    // 立刻同步
    [defaults synchronize];
    // 返回个人资料页面
    [self.navigationController popViewControllerAnimated:YES];
}

@end
