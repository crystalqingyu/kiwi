//
//  DateChooseViewController.m
//  Macaca
//
//  Created by Julie on 14/12/18.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "DateChooseViewController.h"

@interface DateChooseViewController ()

@property (weak, nonatomic) IBOutlet UIView *insideView;
- (IBAction)pickToday:(UIButton *)sender;
- (IBAction)submit:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) NSDate* date;
@property (weak, nonatomic) IBOutlet UIButton *todayBtn;
- (IBAction)clickPicker:(UIDatePicker *)sender;

@end

@implementation DateChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日期选择";
    self.todayBtn.layer.cornerRadius = 10;
    // 设置“选择今天按钮”是否可用
    NSDateFormatter *df = [[NSDateFormatter  alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    if ([[df stringFromDate:self.chooseDate] isEqualToString:[df stringFromDate:[NSDate date]]]) {
        [self.todayBtn setEnabled:NO];
    } else {
        [self.todayBtn setEnabled:YES];
    }
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.date = self.chooseDate; // 初始化_datePicker
    _date = _datePicker.date;
    // 修改insideView大小，确保内部空间伸缩正常显示
    self.insideView.frame = self.view.frame;
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

// 监听时间选择器
- (IBAction)clickPicker:(UIDatePicker *)sender {
    _date = sender.date;
    // 设置“选择今天按钮”是否可用
    NSDateFormatter *df = [[NSDateFormatter  alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    if ([[df stringFromDate:sender.date] isEqualToString:[df stringFromDate:[NSDate date]]]) {
        [self.todayBtn setEnabled:NO];
    } else {
        [self.todayBtn setEnabled:YES];
    }
}
// 监听"选择今天"按钮
- (IBAction)pickToday:(UIButton *)sender {
    // 手动选择时间
    [_datePicker setDate:[NSDate date]];
    // 手动监听时间选择器
    [self clickPicker:_datePicker];
}
// 监听确定按钮
- (IBAction)submit:(UIButton *)sender {
    // 时间传送给代理
    [self.delegate didPopToActQueryViewController:_date];
    // 跳到上一个控制器
    [self.navigationController popViewControllerAnimated:YES];
}

@end
