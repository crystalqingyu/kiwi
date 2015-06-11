//
//  WeightViewController.m
//  Macaca
//
//  Created by Julie on 14/12/12.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "WeightViewController.h"

@interface WeightViewController () <UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, copy) NSString* weight;

@end

@implementation WeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"体重";
    // 添加选择器
    UIPickerView* pikerView = [[UIPickerView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height*0.2, self.view.frame.size.width-2*10, 20)];
    [self.view addSubview:pikerView];
    [pikerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:pikerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.00f];
    [self.view addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:pikerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.00f];
    [self.view addConstraint:constraint];
    //设置代理与数据源
    pikerView.delegate = self;
    pikerView.dataSource = self;
    // 初始化选择器
    NSString* initWeight = [[NSUserDefaults standardUserDefaults] objectForKey:@"weight"];
    [pikerView selectRow:[initWeight intValue] inComponent:0 animated:NO];
    [self pickerView:pikerView didSelectRow:[initWeight intValue] inComponent:0];
//    // 添加对应lable显示选择身高
//    UILabel* weightLable = [[UILabel alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height*0.7, (self.view.frame.size.width-2*10)*0.5, 30)];
//    //dateLable.backgroundColor = [UIColor grayColor];
//    weightLable.layer.borderColor = [UIColor lightGrayColor].CGColor;// 边框颜色,要为CGColor
//    weightLable.layer.borderWidth = 1;// 边框宽度
//    weightLable.layer.cornerRadius = 10;  // lable圆角
//    [self.view addSubview:weightLable];
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
    constraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:pikerView attribute:NSLayoutAttributeBottom multiplier:1.1f constant:0.00f];
    [self.view addConstraint:constraint]; // 顶端位置
    // 监听按钮
    [button addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// pickerView数据源
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component==1) {
        return 1;
    }
    return 200;
}
// pickerView代理
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component==1) {
        return @"kg";
    }
    return [NSString stringWithFormat:@"%d",row];
}
// 监听选择了某一体重
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.weight = [self pickerView:pickerView titleForRow:row forComponent:component];
}
// 确定按钮
- (void)submit {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    // 存储数据
    [defaults setObject:[NSString stringWithFormat:@"%@",self.weight] forKey:@"weight"];
    // 立刻同步
    [defaults synchronize];
    // 返回个人资料界面
    [self.navigationController popViewControllerAnimated:YES];
}

@end