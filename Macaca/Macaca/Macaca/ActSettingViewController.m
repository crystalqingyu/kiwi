//
//  ActSettingViewController.m
//  Macaca
//  运动情况设置：是否在主页显示，是否开始运动
//  Created by Julie on 15/1/11.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "ActSettingViewController.h"
#import "ActRecordViewController.h"

@interface ActSettingViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelCalorie;
@property (weak, nonatomic) IBOutlet UISwitch *switchFirstPage;
@property (weak, nonatomic) IBOutlet UIView *insideView;

@end

@implementation ActSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 设置运动图片、名称、大卡数
    _imageView.image = [UIImage imageNamed:self.data[@"icon"]];
    _imageView.layer.cornerRadius = 10;
    _imageView.layer.borderWidth = 0.5;
    _labelName.text = self.data[@"title"];
    _labelCalorie.text = [NSString stringWithFormat:@"%@ 大卡/小时",self.data[@"calorie"]];
    // “加入首页”label、开关
    if ([self.data[@"isFirstPage"] isEqualToString:@"1"]) {
        [_switchFirstPage setOn:YES];
    } else {
        [_switchFirstPage setOn:NO];
    }
    [_switchFirstPage addTarget:self action:@selector(clickSwitch:) forControlEvents:UIControlEventValueChanged];
    // 判断是"开始运动"还是"正在进行中"
    if ([self.currentAct isEqualToString:self.data[@"title"]]) { // 正在进行中
        UILabel* labelCurrentActing = [[UILabel alloc] initWithFrame:CGRectMake(320/3, 480*0.65, 320/3, 480/16)]; // 按照4s初始化
        labelCurrentActing.text = @"正在进行中...";
        labelCurrentActing.backgroundColor = [UIColor colorWithRed:255.0/255 green:251.0/255 blue:103.0/255 alpha:1];
        labelCurrentActing.autoresizingMask = 45;
        [self.insideView addSubview:labelCurrentActing];
    } else { // 开始运动
        UIButton* btnStartAct = [[UIButton alloc] initWithFrame:CGRectMake(320/3, 480*0.65, 320/3, 480/16)]; // 按照4s初始化
        btnStartAct.backgroundColor = [UIColor colorWithRed:255.0/255 green:252.0/255 blue:146.0/255 alpha:1];
        btnStartAct.layer.cornerRadius = 10;
        btnStartAct.layer.borderWidth = 0.5;
        [btnStartAct setTitle:@"开始运动" forState:UIControlStateNormal];
        [btnStartAct setTitleColor:[UIColor colorWithRed:11.0/255 green:43.0/255 blue:130.0/255 alpha:1] forState:UIControlStateNormal];
        [btnStartAct setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [btnStartAct addTarget:self action:@selector(clickStartAct) forControlEvents:UIControlEventTouchUpInside];
        btnStartAct.autoresizingMask = 45;
        [self.insideView addSubview:btnStartAct];
    }
    // “返回”按钮
    UIButton* btnReturn = [[UIButton alloc] initWithFrame:CGRectMake(320/3, 480*0.775, 320/3, 480/16)]; // 按照4s初始化
    btnReturn.backgroundColor = [UIColor colorWithRed:255.0/255 green:252.0/255 blue:146.0/255 alpha:1];
    btnReturn.layer.cornerRadius = 10;
    btnReturn.layer.borderWidth = 0.5;
    [btnReturn setTitle:@"返回首页" forState:UIControlStateNormal];
    [btnReturn setTitleColor:[UIColor colorWithRed:11.0/255 green:43.0/255 blue:130.0/255 alpha:1] forState:UIControlStateNormal];
    [btnReturn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//    [btnReturn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [btnReturn addTarget:self action:@selector(clickReturn) forControlEvents:UIControlEventTouchUpInside];
    btnReturn.autoresizingMask = 45;
    [self.insideView addSubview:btnReturn];
    // 修改insideView大小，确保内部空间伸缩正常显示
    self.insideView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 监听“正在进行运动”后“返回首页”按钮
- (void)clickReturn {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 监听“开始运动”按钮
- (void)clickStartAct {
    NSString* title;
    if (self.currentAct==nil) { // 当前没有运动，即将开始运动
        // 出弹框1
        title = [NSString stringWithFormat:@"开始“%@”？",self.data[@"title"]];
    }else { // 现有运动即将被新运动取代
        // 出弹框3
        title = [NSString stringWithFormat:@"结束“%@”，开始“%@”？",self.currentAct, self.data[@"title"]];
    }
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alter show];
}
// 弹框出来后点击“取消”或者“确定”，共4种情况的弹框，弹框2只有取消没有确定按钮
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSLog(@"确定，跳到主界面开始计时");
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddNewAct" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.data, @"receiveKey", nil]];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        NSLog(@"取消");
    }
}

// 监听“是否加入首页开关”
- (void)clickSwitch: (UISwitch*)switchFirstPage {
    if (switchFirstPage.isOn == YES) {
        [self.data setValue:@"1" forKey:@"isFirstPage"];
    } else {
        [self.data setValue:@"0" forKey:@"isFirstPage"];
    }
    // 数据归档
        // 生成需要打开的json文件路径
    NSString* home = NSHomeDirectory(); // 路径
    NSString* docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString* filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"act_full.json"]];
        // 加载json文件
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    if (data==nil) {
        data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"act_full.json" ofType:nil]];
        [data writeToFile:filePath atomically:YES];
    }
        // 将JASON数据转为数组
    NSArray* dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        // 改变isFirstPage
    for (NSDictionary* dict in dataArray) {
        if ([[dict objectForKey:@"sort"] isEqualToString:self.sort]) {
            for (NSDictionary* dictInSort in [dict objectForKey:@"act"]) {
                if ([[dictInSort objectForKey:@"title"] isEqualToString:[self.data objectForKey:@"title"]]) {
                    [dictInSort setValue:[self.data objectForKey:@"isFirstPage"] forKey:@"isFirstPage"];
                    break;
                }
            }
            break;
        }
    }
    data = [NSJSONSerialization dataWithJSONObject:dataArray options:NSJSONWritingPrettyPrinted error:nil];
    [data writeToFile:filePath atomically:YES];
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeIsFirstPage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.data, @"receiveKey", nil]];
}

@end
