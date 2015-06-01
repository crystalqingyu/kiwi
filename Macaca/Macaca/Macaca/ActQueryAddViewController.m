//
//  ActQueryAddViewController.m
//  Macaca
//
//  Created by Julie on 15/1/15.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "ActQueryAddViewController.h"
#import "ActDataFile.h"

@interface ActQueryAddViewController ()

@property (weak, nonatomic) IBOutlet UIView *insideView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelCalorie;
@property (weak, nonatomic) IBOutlet UIDatePicker *pickerFirst; // 设置开始时间
@property (nonatomic, strong) IBOutlet UIDatePicker* pickerEnd; // 设置结束时间
@property (nonatomic, strong) IBOutlet UILabel* labelPeriod; // 当前时间段提示
@property (nonatomic, strong) IBOutlet UIButton* btnSubmit; // 提交记录按钮
@property (nonatomic, strong) NSMutableArray* arrayPeriods; // 将dict[@"acts"]中字符串转成NSDate*后的时间段数组
@property (nonatomic, assign) int index; // 添加记录的位置

@property (assign, nonatomic) double weight;

@end

@implementation ActQueryAddViewController

- (void)viewWillAppear:(BOOL)animated {
    self.weight = [[[NSUserDefaults standardUserDefaults] objectForKey:@"weight"] doubleValue];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.title = @"添加运动";
    NSLog(@"%@,%@",self.dateStr,self.arrayPeriods);
    self.view.backgroundColor = [UIColor whiteColor];
    // 设置控制器代理——根控制器
    self.delegate = self.navigationController.viewControllers[0];
    // 设置运动图片、名称、大卡数
    _imageView.image = [UIImage imageNamed:self.data[@"icon"]];
    _imageView.layer.cornerRadius = 10;
    _imageView.layer.borderWidth = 0.5;
    _labelName.text = self.data[@"title"];
    _labelCalorie.text = [NSString stringWithFormat:@"%@ 大卡/小时",self.data[@"calorie"]];
    // 设置开始时间、结束时间
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString* currentDayStr = [dateFormat stringFromDate:[NSDate date]];
    if ([self.dateStr isEqualToString:currentDayStr]) { // 今天
        _pickerFirst.maximumDate = [NSDate date];
        _pickerEnd.maximumDate = [NSDate date];
    }
    [_pickerFirst addTarget:self action:@selector(clickPickerFirst:) forControlEvents:UIControlEventValueChanged];
    [_pickerEnd setUserInteractionEnabled:NO];
    [_pickerEnd addTarget:self action:@selector(clickPickerEnd:) forControlEvents:UIControlEventValueChanged];
    // 确定按钮
    [_btnSubmit setEnabled:NO]; // 默认不可选
    [_btnSubmit addTarget:self action:@selector(clickSubmit) forControlEvents:UIControlEventTouchUpInside];
    // 返回按钮（有没有待定）
    // 修改insideView大小，确保内部空间伸缩正常显示
    self.insideView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
// 如果_acts为空，为_acts分配内存
- (NSMutableArray*)acts {
    if (_acts==nil) {
        _acts = [NSMutableArray array];
    }
    return _acts;
}
// 为_arrayPeriods赋值
- (NSMutableArray*)arrayPeriods {
    if (_arrayPeriods==nil) {
        _arrayPeriods = [NSMutableArray array];
        // 取出原数组
        NSMutableArray* arrayPeriodsStr = self.acts;
        // 原数组中的str转成NSDate*，并添加到_arrayPeriods中
        for (NSDictionary* dict in arrayPeriodsStr) {
            // 日期假设为今天的日期（反正只是用来比较时间的，用不上）
            NSDateFormatter* dayFormat = [[NSDateFormatter alloc] init];
            [dayFormat setDateFormat:@"yyyy-MM-dd"];
            NSString* dayStr = [dayFormat stringFromDate:[NSDate date]];
            // 时间转化
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate* firstDate = [dateFormat dateFromString:[NSString stringWithFormat:@"%@ %@",dayStr,dict[@"firstTimeStr"]]];
            NSDate* endDate = [dateFormat dateFromString:[NSString stringWithFormat:@"%@ %@",dayStr,dict[@"endTimeStr"]]];
            // 添加到全局数组中
            NSDictionary* dictDate = [[NSDictionary alloc] initWithObjectsAndKeys:dict[@"name"],@"name",firstDate,@"firstDate",endDate,@"endDate",dict[@"calorie"],@"calorie",nil];
            [_arrayPeriods addObject:dictDate];
        }
    }
    return _arrayPeriods;
}

- (void)clickPickerFirst: (UIDatePicker*)pickerFirst {
    // 判断是否合理，（1）设置pickerEnd，（2）并且设置确定按钮是否可选，（3）设置labelPeriod，安排一个好算法！！！
    // 当前日期、时间的str
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    NSString* currentDayStr = [dateFormat stringFromDate:[NSDate date]];
    NSString* currentTimeStr = [timeFormat stringFromDate:[NSDate date]];
    int i;
    if (self.arrayPeriods.count==0) { // 当前还没有记录
        self.pickerEnd.userInteractionEnabled = YES;
        self.btnSubmit.enabled = YES;
        if ([self.dateStr isEqualToString:currentDayStr]) {// 今天
            self.labelPeriod.text = [NSString stringWithFormat:@"空闲时间：00:00-%@",currentTimeStr];
            self.pickerEnd.minimumDate = pickerFirst.date;
        } else {
            self.labelPeriod.text = @"空闲时间：00:00-23:59";
        }
        return;
    }
    for (i = 0; i<self.arrayPeriods.count; i++) {
        if ([pickerFirst.date compare:self.arrayPeriods[i][@"endDate"]]==NSOrderedAscending) { // 找到合适时间段
            if ([pickerFirst.date compare:self.arrayPeriods[i][@"firstDate"]]==NSOrderedAscending) { // 可用时间段
                NSLog(@"可用的时间段");
                self.index = i; // 为index赋值
                self.pickerEnd.userInteractionEnabled = YES;
                self.btnSubmit.enabled = YES;
                self.pickerEnd.minimumDate = pickerFirst.date;
                self.pickerEnd.maximumDate = self.arrayPeriods[i][@"firstDate"];
                if (i==0) { // 最开始的时间段
                    NSLog(@"可用，最开始的时间段");
                    NSString* labelStr = [self.acts[i][@"firstTimeStr"] substringToIndex:5];
                    self.labelPeriod.text = [NSString stringWithFormat:@"空闲时间：00:00-%@",labelStr];
                } else {
                    NSLog(@"可用，但不是最开始的时间段");
                    NSString* labelFirstStr = [self.acts[i-1][@"endTimeStr"] substringToIndex:5];
                    NSString* labelEndStr = [self.acts[i][@"firstTimeStr"] substringToIndex:5];
                    self.labelPeriod.text = [NSString stringWithFormat:@"空闲时间：%@-%@",labelFirstStr,labelEndStr];
                }
            } else { // 不可用时间段
                // label设置提示
                NSLog(@"不可用时间段");
                self.btnSubmit.enabled = NO;
                self.pickerEnd.userInteractionEnabled = NO;
                if (i==0 && i==self.arrayPeriods.count-1) { // 包含00:00和23:59
                    if ([self.dateStr isEqualToString:currentDayStr]) { // 今天
                        self.labelPeriod.text = [NSString stringWithFormat:@"该时间段已被占用，建议选择：00:00-%@或%@-%@",[self.acts[i][@"firstTimeStr"] substringToIndex:5],[self.acts[i][@"endTimeStr"] substringToIndex:5],currentTimeStr];
                    } else {
                        self.labelPeriod.text = [NSString stringWithFormat:@"该时间段已被占用，建议选择：00:00-%@或%@-23:59",[self.acts[i][@"firstTimeStr"] substringToIndex:5],[self.acts[i][@"endTimeStr"] substringToIndex:5]];
                    }
                } else if (i==0) { // 包含00:00
                    self.labelPeriod.text = [NSString stringWithFormat:@"该时间段已被占用，建议选择：00:00-%@或%@-%@",[self.acts[i][@"firstTimeStr"] substringToIndex:5],[self.acts[i][@"endTimeStr"] substringToIndex:5],[self.acts[i+1][@"firstTimeStr"] substringToIndex:5]];
                } else if (i==self.arrayPeriods.count-1) { // 包含23:59
                    if ([self.dateStr isEqualToString:currentDayStr]) { // 今天
                        self.labelPeriod.text = [NSString stringWithFormat:@"该时间段已被占用，建议选择：%@-%@或%@-%@",[self.acts[i-1][@"endTimeStr"] substringToIndex:5],[self.acts[i][@"firstTimeStr"] substringToIndex:5],[self.acts[i][@"endTimeStr"] substringToIndex:5],currentTimeStr];
                    } else {
                        self.labelPeriod.text = [NSString stringWithFormat:@"该时间段已被占用，建议选择：%@-%@或%@-23:59",[self.acts[i-1][@"endTimeStr"] substringToIndex:5],[self.acts[i][@"firstTimeStr"] substringToIndex:5],[self.acts[i][@"endTimeStr"] substringToIndex:5]];
                    }
                } else { // 彻底查数组就可
                    self.labelPeriod.text = [NSString stringWithFormat:@"该时间段已被占用，建议选择：%@-%@或%@-%@",[self.acts[i-1][@"endTimeStr"] substringToIndex:5],[self.acts[i][@"firstTimeStr"] substringToIndex:5],[self.acts[i][@"endTimeStr"] substringToIndex:5],[self.acts[i+1][@"firstTimeStr"] substringToIndex:5]];
                }
            }
            break;
        }
    }
    if (i==self.arrayPeriods.count) { // 末尾可用时间段
        NSLog(@"末尾可用时间段");
        self.index = i; // 为index赋值
        self.pickerEnd.userInteractionEnabled = YES;
        self.btnSubmit.enabled = YES;
        self.pickerEnd.minimumDate = pickerFirst.date;
        self.pickerEnd.maximumDate = nil;
        // label设置
        NSString* labelStr = [self.acts[i-1][@"endTimeStr"] substringToIndex:5];
        self.labelPeriod.text = [NSString stringWithFormat:@"空闲时间：%@-23:59",labelStr];
        if ([self.dateStr isEqualToString:currentDayStr]) { // 今天
            // 修改
            self.pickerEnd.maximumDate = [NSDate date];
            self.labelPeriod.text = [NSString stringWithFormat:@"空闲时间：%@-%@",labelStr,currentTimeStr];
        }
    }
}

- (void)clickPickerEnd: (UIDatePicker*)pickerEnd {

}

- (void)clickSubmit {
//    NSLog(@"%@",self.arrayPeriods);
    // 更新文件
    [self updateData];
    // 跳到上一个控制器
        //dateStr转成date类型
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [dateFormat dateFromString:self.dateStr];
    [self.delegate didPopToActQueryViewControllerAdd:date];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)updateData {
    // 体重调整calorie
    NSString* calorie = self.data[@"calorie"];
    calorie = [NSString stringWithFormat:@"%f",[calorie doubleValue]*self.weight/48.5];
    // 将2个datePicker的设置转成字符串：firstTimeStr endTimeStr
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    NSString* firstTimeStr = [timeFormat stringFromDate:_pickerFirst.date];
    NSString* endTimeStr = [timeFormat stringFromDate:_pickerEnd.date];
    // 添加记录
    NSMutableArray* array = [self.acts mutableCopy];
    [array insertObject:[NSDictionary dictionaryWithObjectsAndKeys:self.data[@"title"],@"name",firstTimeStr,@"firstTimeStr", endTimeStr, @"endTimeStr",calorie,@"calorie", nil] atIndex:self.index];
    // 存储
    ActDataFile* file = [[ActDataFile alloc] init];
    file.actData = array;
    file.dateStr = self.dateStr;
    [file saveWithActData];
}

@end
