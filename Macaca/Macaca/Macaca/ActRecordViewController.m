//
//  ActRecordViewController.m
//  Macaca
//
//  Created by Julie on 14/12/9.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "ActRecordViewController.h"
#import "ActRecordCellItem.h"
#import "ActRecordCell.h"
#import "ActItem.h"
#import "ActFullViewController.h"
#import "AppDelegate.h"
#import "ActDataFile.h"
#import "ShareViewController.h"
#import "LXReorderableCollectionViewFlowLayout.h"

#define changeBorder 2.0

@interface ActRecordViewController ()<AppDelegeteWillTerminateDelegate,LXReorderableCollectionViewDataSource,LXReorderableCollectionViewDelegateFlowLayout>

@end

@implementation ActRecordViewController

static NSString * const reuseIdentifier = @"ActRecordCell";

// 从json文件中导入数据：act.json
- (NSMutableArray*)data {
    if (_data==nil) {
        // 生成需要打开的json文件路径
        NSString* home = NSHomeDirectory(); // 路径
        NSString* docPath = [home stringByAppendingPathComponent:@"Documents"];
        NSString* filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"act.json"]];
        // 加载json文件
        NSData* data = [NSData dataWithContentsOfFile:filePath];
        if (data==nil) {
            data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"act.json" ofType:nil]];
            [data writeToFile:filePath atomically:YES];
        }
        // 将JASON数据转为数组
        NSArray* dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        // 将数组中字典转为模型
        NSMutableArray* dataMutableArray = [NSMutableArray array];
        for (NSDictionary* dict in dataArray) {
            ActRecordCellItem* item = [ActRecordCellItem actRecordCellItemWithDict:dict];
            [dataMutableArray addObject:item];
        }
        _data = dataMutableArray;
    }
    return _data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置程序退出前的代理
    UIApplication* app = [UIApplication sharedApplication];
    AppDelegate* delegate = app.delegate;
    delegate.willTerminateDelegate = self;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    UINib* nib = [UINib nibWithNibName:@"ActRecordCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
    // 重新排布collectionView的layout
    LXReorderableCollectionViewFlowLayout* layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.view.frame.size.width/3, self.view.frame.size.width/3);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(layout.minimumLineSpacing, 0, 0, 0);
    self.collectionView.collectionViewLayout = (UICollectionViewLayout*)layout;
    
    // 接受回传“开始运动”通知
    [[NSNotificationCenter defaultCenter] addObserver:[self.navigationController viewControllers][0] selector:@selector(addNewAct:) name:@"AddNewAct" object:nil];
    // 接受回传“加入首页”通知
    [[NSNotificationCenter defaultCenter] addObserver:[self.navigationController viewControllers][0] selector:@selector(changeIsFirstPage:) name:@"ChangeIsFirstPage" object:nil];
    // 创建按钮播放器
    // _btnSound = kSystemSoundID_Vibrate;//震动
    NSString *path = @"/System/Library/Audio/UISounds/Tock.caf";
    if (path) {
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&_btnSound);
        
        if (error != kAudioServicesNoError) {//获取的声音的时候，出现错误
            _btnSound = nil;
        }
    }
//    // 添加LXReorderableCollectionViewLayout
//    LXReorderableCollectionViewFlowLayout* reorderLayout = [[LXReorderableCollectionViewFlowLayout alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    self.weight = [[[NSUserDefaults standardUserDefaults] objectForKey:@"weight"] doubleValue];
}

- (void)viewDidAppear:(BOOL)animated {
    // 读取lastDict
    NSDictionary* lastDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastDict"];
    if (lastDict!=nil) {
        ActRecordCellItem* item = [[ActRecordCellItem alloc] init];
        item.title = [lastDict objectForKey:@"lastCurrentActTitle"];
        item.icon = [lastDict objectForKey:@"lastCurrentActIcon"];
        item.calorie = [lastDict objectForKey:@"lastCurrentActCalorie"];
        NSDate* lastStartDate = [lastDict objectForKey:@"lastStartDate"];
        // 设置当前运动
        self.lastAct = self.currentAct;
        self.currentAct = item;
        // 开启计时
            [self startAction:item];
        // lastStartDate清空
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastDict"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 新建cell
    ActRecordCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    // 取出data对应的item
    ActRecordCellItem* item = _data[indexPath.row];
    // 给cell赋值
    cell.actItem = item;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

// 点击cell的代理
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 播放声音
    AudioServicesPlaySystemSound(_btnSound);
    // 设置选中状态
//    [collectionView cellForItemAtIndexPath:indexPath].backgroundColor = [UIColor colorWithRed:244.0/255 green:195.0/255 blue:194.0/255 alpha:1];
    ActRecordCell* cell = (ActRecordCell*)[collectionView cellForItemAtIndexPath:indexPath];
    CGRect borderFrame = cell.borderView.frame;
    cell.borderView.frame = CGRectMake(borderFrame.origin.x-changeBorder, borderFrame.origin.y-changeBorder, borderFrame.size.width+2*changeBorder, borderFrame.size.width+2*changeBorder);
    cell.borderView.backgroundColor = [UIColor colorWithRed:244.0/255 green:195.0/255 blue:194.0/255 alpha:1];
    // 取出当前运动，并赋值上一个运动
    self.lastAct = self.currentAct;
    self.currentAct = _data[indexPath.row];
    ActRecordCellItem* item = self.currentAct;
    if (_currentStateView==nil) { // 当前没有活动
        // 出弹框1
        NSString* title = [NSString stringWithFormat:@"开始“%@”？",item.title];
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alter show];
    } else { // 当前有活动
        if ([_titleLable.text isEqualToString:item.title]) {// 点击的时当前活动
            // 时间暂停，记录结束时间
            [_timer setFireDate:[NSDate distantFuture]];
            _pauseDate = [NSDate date];
            // 出弹框2
            NSString* title = [NSString stringWithFormat:@"正在进行“%@”...",item.title];
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
        } else {
            // 时间暂停，记录结束时间
            [_timer setFireDate:[NSDate distantFuture]];
            _pauseDate = [NSDate date];
            // 出弹框3
            NSString* title = [NSString stringWithFormat:@"结束“%@”，开始“%@”？",_titleLable.text, item.title];
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alter show];
        }
    }
}

// 弹框出来后点击“取消”或者“确定”，共4种情况的弹框，弹框2只有取消没有确定按钮
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // 取消选中状态
    if ([self.collectionView indexPathsForSelectedItems].count>0) {
//        [self.collectionView cellForItemAtIndexPath:[self.collectionView indexPathsForSelectedItems][0]].backgroundColor = [UIColor whiteColor];
        ActRecordCell* cell = (ActRecordCell*)[self.collectionView cellForItemAtIndexPath:[self.collectionView indexPathsForSelectedItems][0]];
        CGRect borderFrame = cell.borderView.frame;
        cell.borderView.frame = CGRectMake(borderFrame.origin.x+changeBorder, borderFrame.origin.y+changeBorder, borderFrame.size.width-2*changeBorder, borderFrame.size.width-2*changeBorder);
        cell.borderView.backgroundColor = [UIColor colorWithRed:193.0/255 green:193.0/255 blue:193.0/255 alpha:1];
    }
    // 取出item
    ActRecordCellItem* item = self.currentAct;
    // 点击的是“确定”
    if (buttonIndex == 1)
    {
        // “确定添加运动”的弹框1
        if (_currentStateView==nil) {
            [self startAction:item];
        } else {
            if ([item.title isEqualToString:_titleLable.text]) {// “确定退出运动”的弹框4
                [UIView animateWithDuration:0.5 animations:^(void){
                    CGFloat x = _currentStateView.center.x;
                    CGFloat y = _currentStateView.center.y-_currentStateView.frame.size.height;
                    _currentStateView.center = CGPointMake(x, y);
                }completion:^(BOOL finished){
                    // 结束当前计时
                    [_timer invalidate];
                    // 移除currentView
                    [_currentStateView removeFromSuperview];
                    _currentStateView = nil;
                    // 上移collectionView
                    NSRange range;
                    range.length = 3;
                    range.location = 0;
                    [_data removeObjectsInRange:range];
                    [self.collectionView reloadData];
                    // 当前运动、上个运动、回传的运动全部清空
                    self.currentAct = nil;
                    self.lastAct = nil;
                    // 存储数据
                    [self saveAct:item.title calorie:item.calorie];
                }];

                
            } else { // “当前运动替换为新运动”弹框3
                // 结束当前计时
                [_timer invalidate];
                // 存储数据
                [self saveAct:_titleLable.text calorie:self.lastAct.calorie];
                // 开启新一轮计时
                // 标题
                _titleLable.text = item.title;
                // 计时和热量
                _startDate = [NSDate date];
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
            }
        }
    } else { // 点击的是取消
        // “某活动正在进行中”弹框2 、“当前活动替换为新运动”弹框3、“结束当前运动”弹框4
        if (_currentStateView != nil) {
            if (![item.title isEqualToString:_titleLable.text]) {// 取消“当前活动替换为新运动”
                self.currentAct = self.lastAct;
            }
            // 时间继续
            [_timer setFireDate:[NSDate distantPast]];
            // 存储数据
        }
    }
}

// 点击”结束“按钮
- (IBAction)cancelBtn:(UIButton *)sender {
    // 播放按钮声音
    AudioServicesPlaySystemSound(_btnSound);
    // 时间暂停，记录结束时间
    [_timer setFireDate:[NSDate distantFuture]];
    _pauseDate = [NSDate date];
    // 出弹框4
    NSString* title = [NSString stringWithFormat:@"结束“%@”？",self.currentAct.title];
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alter show];
}

// 存储运动数据
- (void)saveAct: (NSString*)actName calorie: (NSString*)calorie {
    // 判断是否跨天再做处理：起始时间与暂停时间是否是同一天
    NSDateFormatter* dayFormat = [[NSDateFormatter alloc] init];
    [dayFormat setDateFormat:@"yyyy-MM-dd"];
    NSString* startDateStr = [dayFormat stringFromDate:self.startDate];
    NSString* pauseDateStr = [dayFormat stringFromDate:self.pauseDate];
    if ([startDateStr isEqualToString:pauseDateStr]) { // 没跨天
        [self save:actName startDate:self.startDate pauseDate:self.pauseDate date:self.startDate calorie: calorie];
    } else { // 跨天，有可能跨月份，跨N天：分三部分计算
        // 存储前面的小时
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* pauseDate = [dateFormat dateFromString:[startDateStr stringByAppendingString:@" 23:59:59"]];
            // 存储
        [self save:actName startDate:self.startDate pauseDate:pauseDate date:self.startDate calorie:calorie];
        NSDate* startDate = [dateFormat dateFromString:[[dayFormat stringFromDate:self.startDate] stringByAppendingString:@" 00:00:00"]];
        // 存储中间若干整天
        while ([self.pauseDate timeIntervalSinceDate:pauseDate]>60*60*24) {
            pauseDate = [pauseDate initWithTimeInterval:60*60*24 sinceDate:pauseDate];
            startDate = [startDate initWithTimeInterval:60*60*24 sinceDate:startDate];
            [self save:actName startDate:startDate pauseDate:pauseDate date:startDate calorie:calorie];
        }
        // 存储后面剩的小时
        [self save:actName startDate:[dateFormat dateFromString:[[dayFormat stringFromDate:self.pauseDate] stringByAppendingString:@" 00:00:00"]] pauseDate:self.pauseDate date:self.pauseDate calorie:calorie];
    }
}
- (void)save: (NSString*)actName startDate: (NSDate*)startDate pauseDate: (NSDate*)pauseDate date: (NSDate*)date calorie: (NSString*)calorie {
    // 体重调整calorie
    calorie = [NSString stringWithFormat:@"%f",[calorie doubleValue]*self.weight/48.5];
    // 日期字符串
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString* dateStr = [dateFormat stringFromDate:date];
    // 存储数据生成
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    NSString *firstTimeStr = [timeFormat stringFromDate:startDate];
    NSString *endTimeStr = [timeFormat stringFromDate:pauseDate];
    NSDictionary* actDict = [NSDictionary dictionaryWithObjectsAndKeys:actName,@"name",firstTimeStr,@"firstTimeStr",endTimeStr,@"endTimeStr",calorie,@"calorie", nil];
    // 添加记录
    ActDataFile* file = [[ActDataFile alloc] init];
    file.dateStr = dateStr;
    file.actRecord = actDict;
    [file addWithActRecord];
}

// 监听“搜索运动”放大镜按钮
- (IBAction)jumpToActFull{
    if (_currentStateView!=nil) {
        [self performSegueWithIdentifier:@"JumpToActFullViewController" sender:_titleLable.text];
    } else {
        [self performSegueWithIdentifier:@"JumpToActFullViewController" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString* title = sender;
    ActFullViewController* desVc = segue.destinationViewController;
    desVc.currentAct = title;
}

- (IBAction)jumpToShare:(UIBarButtonItem *)sender {
    ShareViewController* shareVc=[[ShareViewController alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        
        shareVc.modalPresentationStyle=UIModalPresentationOverFullScreen;
        
    }else{
        
        self.modalPresentationStyle=UIModalPresentationCurrentContext;
        
    }
    [self.navigationController presentViewController:shareVc animated:YES completion:nil];
    
}

// 广播监听：搜索运动后开始运动
- (void)addNewAct: (NSNotification*)notification {
    // 取出监听数据
    NSDictionary* userInfo = [notification userInfo];
    NSDictionary* dict = [userInfo objectForKey: @"receiveKey"];
    ActRecordCellItem* item = [[ActRecordCellItem alloc] init];
    item.icon = dict[@"icon"];
    item.title = dict[@"title"];
    item.calorie = dict[@"calorie"];
    // 设置当前运动
    self.lastAct = self.currentAct;
    self.currentAct = item;
    // “确定添加运动”的弹框1
    if (_currentStateView==nil) {
        [self startAction:item];
    } else { // “当前运动替换为新运动”弹框3
            // 结束当前计时，记录结束时间
            [_timer invalidate];
            _pauseDate = [NSDate date];
            // 存储数据
            [self saveAct:_titleLable.text calorie:self.lastAct.calorie];
            // 开启新一轮计时
            // 标题
            _titleLable.text = item.title;
            // 计时和热量
            _startDate = [NSDate date];
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    }
}

// 广播监听：改变是否在首页显示
- (void)changeIsFirstPage: (NSNotification*)notification {
    // 取出监听数据
    NSDictionary* userInfo = [notification userInfo];
    NSDictionary* dict = [userInfo objectForKey: @"receiveKey"];
    if ([[dict objectForKey:@"isFirstPage"] isEqualToString:@"0"]) { // 从首页中移除
        for (ActRecordCellItem* item in self.data) {
            if ([item.title isEqualToString:[dict objectForKey:@"title"]]) {
                // 删除数据源
                [self.data removeObject:item];
                // 刷新表格
                [self.collectionView reloadData];
                break;
            }
        }
    } else { //加入到首页中
        // 加入数据源
        ActRecordCellItem* item = [[ActRecordCellItem alloc] init];
        item.title = [dict objectForKey:@"title"];
        item.icon = [dict objectForKey:@"icon"];
        item.calorie = [dict objectForKey:@"calorie"];
        [self.data addObject:item];
        // 刷新表格
        [self.collectionView reloadData];
    }
    // 归档
        // 生成需要打开的json文件路径
    NSString* home = NSHomeDirectory(); // 路径
    NSString* docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString* filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"act.json"]];
        // 加载json文件
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    if (data==nil) {
        data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"act.json" ofType:nil]];
        [data writeToFile:filePath atomically:YES];
    }
        // 将JASON数据转为数组
    NSArray* dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        // 将数组中字典转为模型
    NSMutableArray* dataMutableArray = [NSMutableArray arrayWithArray:dataArray];
    if ([[dict objectForKey:@"isFirstPage"] isEqualToString:@"0"]) { // 从首页中移除
        for (NSDictionary* dictInData in dataArray) {
            if ([[dictInData objectForKey:@"title"] isEqualToString:[dict objectForKey:@"title"]]) {
                [dataMutableArray removeObject:dictInData];
            }
        }
    }else { //加入到首页中
        NSDictionary* dictAdd = [NSDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:@"title"],@"title",[dict objectForKey:@"icon"],@"icon",[dict objectForKey:@"calorie"],@"calorie", nil];
        [dataMutableArray addObject:dictAdd];
    }
    data = [NSJSONSerialization dataWithJSONObject:dataMutableArray options:NSJSONWritingPrettyPrinted error:nil];
    [data writeToFile:filePath atomically:YES];
}

// appDelegateWillTerminate代理实现：退出程序时执行的
- (void)saveLastRecord {
    if (_currentStateView!=nil) {
        // 系统默认偏好设置
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        // 存储数据（不能存自定义ActRecordCellItem，只能分开存了）
        NSDictionary* lastDict = [NSDictionary dictionaryWithObjectsAndKeys:self.startDate,@"lastStartDate",self.currentAct.title,@"lastCurrentActTitle",self.currentAct.icon,@"lastCurrentActIcon",self.currentAct.calorie,@"lastCurrentActCalorie", nil];
        [defaults setObject:lastDict forKey:@"lastDict"];
    }
}

// 开始记录运动
- (void)startAction: (ActRecordCellItem*)item {
    NSArray* greenViews = [[NSBundle mainBundle] loadNibNamed:@"CurrentState" owner:self options:nil];
    UIView* view = greenViews[0];
    view.frame = CGRectMake(0, 64-self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.width/3);// 如果navigationBar有背景图，则y坐标要设为0，否则设为64
    // 缓慢添加View
    [UIView animateWithDuration:0.7 animations:^(void){
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width/3);// 如果navigationBar有背景图，则y坐标要设为0，否则设为64
        // 结束按钮设为圆角
        self.cancelButton.layer.cornerRadius = self.cancelButton.frame.size.width/2;
        // 标题
        self.titleLable.text = item.title;
        // 计时和热量
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastDict"]!=nil) { // 接着上次退出记录
            self.startDate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastDict"] objectForKey:@"lastStartDate"];
        } else { // 开启新纪录
            self.startDate = [NSDate date];
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        [self.view addSubview:view];
    }completion:^(BOOL finished){
        // cell下移
        for (int i = 0; i<3; i++) {
            ActRecordCellItem* item = [[ActRecordCellItem alloc] init];
            [self.data insertObject:item atIndex:0];
        }
        // 更新view，并且设置当前位置+4号为选中状态
        [self.collectionView reloadData];
    }];
}

// 计时器
- (void) updateTime{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    self.timeLable.text = timeString;
    // 热量计算
    ActRecordCellItem* item = [[ActRecordCellItem alloc] init];
    item = self.currentAct;
    self.calorieLable.text = [NSString stringWithFormat:@"%.1f",(double)timeInterval*([item.calorie doubleValue]*self.weight/48.5/3600)]; // 需要将热量由字符串转为float
    // 设置“结束”按钮颜色
    double calorie = (double)timeInterval*([item.calorie doubleValue]*self.weight/48.5/3600);
    if (calorie<=0) {
        calorie = -calorie;
    }
    double y = 255/(1+254.0*exp(-0.5*calorie));
    self.cancelButton.backgroundColor = [UIColor colorWithRed:y/255.0 green:195.0/255 blue:150.0/255 alpha:0.98];
}

#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    ActRecordCellItem *item = self.data[fromIndexPath.item];
    
    [self.data removeObjectAtIndex:fromIndexPath.item];
    [self.data insertObject:item atIndex:toIndexPath.item];
    // 归档
      // 生成需要打开的json文件路径
    NSString* home = NSHomeDirectory(); // 路径
    NSString* docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString* filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"act.json"]];
      // 交换位置
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSArray* array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray* mutableArray = [NSMutableArray arrayWithArray:array];
    [mutableArray removeObjectAtIndex:fromIndexPath.row];
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:item.title,@"title",item.icon,@"icon",item.calorie,@"calorie", nil];
    [mutableArray insertObject:dict atIndex:toIndexPath.row];
      // 写文件
    data = [NSJSONSerialization dataWithJSONObject:mutableArray options:NSJSONWritingPrettyPrinted error:nil];
    [data writeToFile:filePath atomically:YES];
}

@end
