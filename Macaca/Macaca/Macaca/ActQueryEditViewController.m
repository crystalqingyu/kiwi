//
//  ActQueryEditViewController.m
//  Macaca
//
//  Created by Julie on 15/1/15.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "ActQueryEditViewController.h"
#import "ActDataFile.h"

@interface ActQueryEditViewController ()
@property (weak, nonatomic) IBOutlet UIView *insideView;
- (IBAction)deleteRecord;
- (IBAction)submitTime;
- (IBAction)clickFirstTime:(UIDatePicker *)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelIdle;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *firstTime;

@end

@implementation ActQueryEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.cell.textLabel.text;
    // 当前时间、日期str
    NSDate* currentDate = [NSDate date];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* currentDateStr = [dateFormat stringFromDate:currentDate];
    NSString* currentDayStr = [currentDateStr substringToIndex:10];
    NSString* currentTimeStr = [currentDateStr substringWithRange:NSMakeRange(11, 5)]; // HH:mm
    // 设置_labelIdle
    if (self.lastCell==nil && self.nextCell==nil) {
        self.labelIdle.text = [NSString stringWithFormat:@"空闲时间：00:00-23:59"];
    } else if (self.lastCell==nil) {
        self.labelIdle.text = [NSString stringWithFormat:@"空闲时间：00:00-%@",[self.nextCell.detailTextLabel.text substringToIndex:5]];
    } else if (self.nextCell==nil) {
        self.labelIdle.text = [NSString stringWithFormat:@"空闲时间：%@-23:59",[self.lastCell.detailTextLabel.text substringWithRange:NSMakeRange(9, 5)]];
    } else {
        self.labelIdle.text = [NSString stringWithFormat:@"空闲时间：%@-%@",[self.lastCell.detailTextLabel.text substringWithRange:NSMakeRange(9, 5)],[self.nextCell.detailTextLabel.text substringToIndex:5]];
    }
    if ([self.dateStr isEqualToString:currentDayStr]) { // 今天
        // 修改_labelIdle
        if (self.lastCell==nil && self.nextCell==nil) {
            self.labelIdle.text = [NSString stringWithFormat:@"空闲时间：00:00-%@",currentTimeStr];
        }
        if (self.nextCell==nil && self.lastCell!=nil) {
            self.labelIdle.text = [NSString stringWithFormat:@"空闲时间：%@-%@",[self.lastCell.detailTextLabel.text substringWithRange:NSMakeRange(9, 5)],currentTimeStr];
        }
    }
    // 2个datePicker的最小最大、当前时间初始化
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
        // 设置当前时间
    NSDate* firstTime = [dateFormat dateFromString:[NSString stringWithFormat:@"%@ %@",self.dateStr,[self.cell.detailTextLabel.text substringToIndex:8]]];
    NSDate* endTime = [dateFormat dateFromString:[NSString stringWithFormat:@"%@ %@",self.dateStr,[self.cell.detailTextLabel.text substringFromIndex:9]]];
    [self.firstTime setDate:firstTime];
    [self.endTime setDate:endTime];
        // 设置最小最大时间(不用区分今天还是以前，以下这样写就OK乐，因为有日期限制，之前的日期比今天的小)
    NSDate* firstMinTime = [dateFormat dateFromString:[NSString stringWithFormat:@"%@ %@",self.dateStr,[self.lastCell.detailTextLabel.text substringFromIndex:9]]];
    NSDate* endMaxTime = [dateFormat dateFromString:[NSString stringWithFormat:@"%@ %@",self.dateStr,[self.nextCell.detailTextLabel.text substringToIndex:8]]];
    if (self.lastCell==nil && self.nextCell==nil) {
        [self.endTime setMinimumDate:self.firstTime.date];
        [self.firstTime setMaximumDate:[NSDate date]];
        [self.endTime setMaximumDate:[NSDate date]];
    } else if (self.lastCell==nil) {
        [self.firstTime setMaximumDate:endMaxTime];
        [self.endTime setMinimumDate:self.firstTime.date];
        [self.endTime setMaximumDate:endMaxTime];
    } else if (self.nextCell==nil) {
        [self.firstTime setMinimumDate:firstMinTime];
        [self.endTime setMinimumDate:self.firstTime.date];
        [self.firstTime setMaximumDate:[NSDate date]];
        [self.endTime setMaximumDate:[NSDate date]];
    } else {
        [self.firstTime setMinimumDate:firstMinTime];
        [self.firstTime setMaximumDate:endMaxTime];
        [self.endTime setMinimumDate:self.firstTime.date];
        [self.endTime setMaximumDate:endMaxTime];
    }
    // 修改insideView大小，确保内部空间伸缩正常显示
    self.insideView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)deleteRecord {
    // 出弹框确认
    NSString* title = [NSString stringWithFormat:@"确定删除“%@”？",self.cell.textLabel.text];
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alter show];
}

- (IBAction)submitTime {
    // 将2个datePicker的设置转成字符串：firstTimeStr endTimeStr
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    NSString* firstTimeStr = [timeFormat stringFromDate:_firstTime.date];
    NSString* endTimeStr = [timeFormat stringFromDate:_endTime.date];
    // 修改文件数据
    ActDataFile* file = [[ActDataFile alloc] init];
    file.dateStr = self.dateStr;
    [file changeWithFirstTimeStr:firstTimeStr endTimeStr:endTimeStr indexNo:[[self.navigationController.viewControllers[0] tableView] indexPathForCell:self.cell].row];
    // 跳到上一个控制器
        //dateStr转成date类型
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [dateFormat dateFromString:self.dateStr];
    [self.delegate didPopToActQueryViewControllerEdit:date];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickFirstTime:(UIDatePicker *)sender {
    // 点击起始时间后，终止时间的最小值改变
    _endTime.minimumDate = sender.date;
}

// 删除按钮的弹框确认
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) { // 确定
        // dateStr转成date类型
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate* date = [dateFormat dateFromString:self.dateStr];
        // 删除记录并存储
        ActDataFile* file = [[ActDataFile alloc] init];
        file.dateStr = self.dateStr;
        [file removeWithIndexNo:[[self.navigationController.viewControllers[0] tableView] indexPathForCell:self.cell].row];
        
        [self.delegate didPopToActQueryViewControllerDelete: date];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
