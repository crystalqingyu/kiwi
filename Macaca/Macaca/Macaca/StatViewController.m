//
//  StatViewController.m
//  Macaca
//
//  Created by ZhangQi on 15/1/12.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "StatViewController.h"
#import "SelectDateViewController.h"

@interface StatViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeWindowSegment;
- (IBAction)segmentChanged:(UISegmentedControl *)sender;
- (IBAction)doSelectDate:(UIBarButtonItem *)sender;
@property (weak, nonatomic) NSDate* selectedDate;
@end

static const int graph_host_top_margin = 64;
static const int graph_host_bottom_margin = 49;

static const int pieFillColorRGB [] = {
    0xFF,0x66,0x66,
    0xff,0xff,0x00,
    0x00,0x66,0x99,
    0xff,0x99,0x66,
    0x00,0x66,0xcc,
    0x33,0x99,0x33,
    0xff,0xcc,0x33,
    0x33,0x66,0x99,
    0xff,0x99,0x00,
    0xff,0xff,0xcc,
    0xcc,0x66,0x00,
    0xcc,0xcc,0x44,
    0x99,0xcc,0x33,
    0x00,0x99,0xcc,
    0x99,0xcc,0xcc,
    0xff,0x00,0x33,
    0x33,0x33,0x99,
    0xcc,0xcc,0x00,
    0x33,0xcc,0x99
};
static const int pieFillColorSize = sizeof(pieFillColorRGB)/sizeof(int)/3;
static const int buttonBGColorRGB [] = {255,252,67};
static const int buttonBorderColorRGB [] = {37,109,199};
static const int buttonTextColorRGB [] = {37,109,199};

@implementation StatViewController

- (void)viewDidLoad {
    NSLog(@"#=#=#=#=#=# viewDidLoad!!");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 默认显示热量
    self.dataSel = 1;
    
    // 默认显示当天
    int timeIdx = 0;
    [self.timeWindowSegment setSelectedSegmentIndex:timeIdx];
    self.timeSel = timeIdx;
    
    // 3.5寸屏幕不显示图例，其余尺寸屏幕显示图例
    self.displayLegend = 1;
    if (self.view.frame.size.height == 480) {
        self.displayLegend = 0;
    }
    
    // 接受回传 StatDateSelected 通知
    //NSLog(@"[self.navigationController viewControllers]=%@",[self.navigationController viewControllers]);
    [[NSNotificationCenter defaultCenter] addObserver:[self.navigationController viewControllers][0] selector:@selector(dateSelected:) name:@"StatDateSelected" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"#=#=#=#=#=# viewWillAppear!!");
    
    [super viewWillAppear:animated];
    
    [self draw];
}

- (double) minuteElapsedFrom:(NSString*) start to:(NSString*) end {
    
    int sec_minus = [[end substringWithRange:NSMakeRange(6, 2)] intValue] - [[start substringWithRange:NSMakeRange(6, 2)] intValue];
    int min_minus = [[end substringWithRange:NSMakeRange(3, 2)] intValue] - [[start substringWithRange:NSMakeRange(3, 2)] intValue];
    int hour_minus = [[end substringWithRange:NSMakeRange(0, 2)] intValue] - [[start substringWithRange:NSMakeRange(0, 2)] intValue];
    //NSLog(@"start:%@, end:%@, elapsedMin:%f",start,end,(hour_minus * 3600 + min_minus * 60 + sec_minus)/60.0);
    return (hour_minus * 3600 + min_minus * 60 + sec_minus)/60.0;
}

- (NSMutableArray*) getRecordArray:(int)day_count {
    return [self getRecordArrayBackwardFrom:0 dayCount:day_count];
}

- (NSMutableArray*) getRecordArrayBackwardFrom:(int)day_ago dayCount:(int)day_count {
    // 日期格式
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    // 生成需要打开的文件路径
    NSString* home = NSHomeDirectory(); // 主目录路径
    NSString* docPath = [home stringByAppendingPathComponent:@"Documents"];
    
    // 返回结构
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    
    //创建文件管理器
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    // 将记录添加进返回结构
    for (int i=0; i<day_count; ++i) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:-86400*(i + day_ago)];
        NSString* dateStr = [dateFormat stringFromDate:date];
        // 活动记录文件的路径
        NSString* filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",[dateStr substringToIndex:7]]];
        NSLog(@"filePath=%@",filePath);
        // 检查文件是否存在
        if (![fileManager fileExistsAtPath:filePath]) {
            continue;
        }
        // 字典中key
        NSString* day = [NSString stringWithFormat:@"%@",[dateStr substringFromIndex:8]];
        // 读取当天的记录
        NSMutableArray* arr = [[NSDictionary dictionaryWithContentsOfFile:filePath] objectForKey:day];
        if (arr==nil) {
            continue;
        }
        // 将arr添加到返回结构的末尾
        [ret addObjectsFromArray:arr];
    }
    
    return ret;
}

- (void)calcPiePlotInfo:(NSMutableArray*) arr {
    // 用于记录每个运动消耗时间/热量的Dictionary
    NSMutableDictionary* act_dict = [[NSMutableDictionary alloc] initWithCapacity:15];
    NSMutableDictionary* act_dict_abs = [[NSMutableDictionary alloc] initWithCapacity:15];
    
    // 计算当天的总量
    self.arrSum = 0.0;
    self.arrNegSum = 0.0;
    
    int i;
    for (i=0; i<[arr count]; ++i) {
        double minute_elapsed = [self minuteElapsedFrom:[[arr objectAtIndex:i] objectForKey:@"firstTimeStr"]  to:[[arr objectAtIndex:i] objectForKey:@"endTimeStr"]];
        double calories_per_hour = [[[arr objectAtIndex:i] objectForKey:@"calorie"] doubleValue];
        
        double act_value = 0.0;
        switch (self.dataSel) {
            case 0:
                act_value = minute_elapsed;
                break;
            case 1:
                act_value = minute_elapsed * calories_per_hour / 60.0;
                break;
            default:
                break;
        }
        
        //累加绝对值
        double act_value_abs = act_value;
        if (act_value<0) {
            act_value_abs = 0.0 - act_value;
            self.arrNegSum += act_value;
        }
        self.arrSum += act_value_abs;
        
        NSString* act_name = [[arr objectAtIndex:i] objectForKey:@"name"];
        NSDecimalNumber* obj = [act_dict objectForKey:act_name];
        NSDecimalNumber* obj_abs = [act_dict_abs objectForKey:act_name];
        if (obj == nil) {
            [act_dict setObject:[NSDecimalNumber numberWithDouble:0.0] forKey:act_name];
            obj = [act_dict objectForKey:act_name];
            [act_dict_abs setObject:[NSDecimalNumber numberWithDouble:0.0] forKey:act_name];
            obj_abs = [act_dict_abs objectForKey:act_name];
        }
        [act_dict setObject:[obj decimalNumberByAdding:(NSDecimalNumber*)[NSDecimalNumber numberWithDouble:act_value]] forKey:act_name];
        [act_dict_abs setObject:[obj_abs decimalNumberByAdding:(NSDecimalNumber*)[NSDecimalNumber numberWithDouble:act_value_abs]] forKey:act_name];
    }
    //NSLog(@"arrSum=%f",self.arrSum);
    NSLog(@"act_dict=%@",act_dict);
    
    // 将 act_dict 和 act_dict_abs 的内容复制到self.allActArr
    self.allActArr = [[NSMutableArray alloc] init];
    NSEnumerator* key_enum = [act_dict keyEnumerator];

    for (NSString* key in key_enum) {
        NSDictionary* dict = @{@"name":key, @"stat_value":[act_dict objectForKey:key], @"stat_value_abs":[act_dict_abs objectForKey:key]};
        [self.allActArr addObject:dict];
    }
    // 排序
    [self.allActArr sortUsingComparator:^NSComparisonResult(__strong id obj1, __strong id obj2) {
        return [[obj1 objectForKey:@"stat_value_abs"] doubleValue] < [[obj2 objectForKey:@"stat_value_abs"] doubleValue];
    }];
}

// 将小于5%的部分计入“其他”
- (void) mergePiePlotInfo {
    self.arr = [[NSMutableArray alloc] init];
    double accumulateSum = 0.0;
    int flag = 0;
    int i = 0;
    for (; i<[self.allActArr count]; i++) {
        NSDictionary* dict = [self.allActArr objectAtIndex:i];
        [self.arr addObject:dict];
        
        // 将stat_value_abs累加进accumulateSum
        double stat_value = [[dict objectForKey:@"stat_value_abs"] doubleValue];
        accumulateSum += stat_value;
        //NSLog(@"accumulateSum=%f,self.arrSum=%f",accumulateSum,self.arrSum);
        if (accumulateSum >= self.arrSum * 0.95) {
            flag = 1;
            break;
        }
    }
    
    double leftSum = self.arrSum - accumulateSum;
    //NSLog(@"leftSum=%f",leftSum);
    if (leftSum > 0.01) {
        double sum = 0.0;
        i += 1;
        for (; i<[self.allActArr count]; i++) {
            sum += [[[self.allActArr objectAtIndex:i] objectForKey:@"stat_value"] doubleValue];
        }
        NSDictionary* dict = @{@"name":@"其他", @"stat_value":[NSDecimalNumber numberWithDouble:sum], @"stat_value_abs":[NSDecimalNumber numberWithDouble:leftSum]};
        [self.arr addObject:dict];
    }
}

- (void)getActInfoYesterday {
    [self calcPiePlotInfo:[self getRecordArrayBackwardFrom:1 dayCount:1]];
}

- (void)getActInfoSelectDay {
    int dayCntBackward = (int)(- self.selectedDate.timeIntervalSinceNow / 86400);
    NSLog(@"getActInfoSelectDay, dayCntBackward=%d",dayCntBackward);
    [self calcPiePlotInfo:[self getRecordArrayBackwardFrom:dayCntBackward dayCount:1]];
}

// 广播监听：已经选择日期
- (void) dateSelected: (NSNotification*)notification {
    NSLog(@"dateSelected: notification");
    self.selectedDate = [[notification userInfo] objectForKey:@"selectedDate"];
    NSLog(@"selectedDate=%@",self.selectedDate);
    
    self.timeWindowSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    self.timeSel = -1;
    
    [self draw];
}

- (void)getActInfoDay:(int)day_offset {
    [self calcPiePlotInfo:[self getRecordArray:1]];
}

- (void)getActInfoWeek:(int)week_offset {
    [self calcPiePlotInfo:[self getRecordArray:7]];
}

- (void)getActInfoMonth:(int)month_offset {
    [self calcPiePlotInfo:[self getRecordArray:30]];
}

- (void)getActInfoYear:(int)year_offset {
    [self calcPiePlotInfo:[self getRecordArray:365]];
}

- (void) pieChartPlot {
    //创建画布
    CGRect graph_frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height - graph_host_top_margin - graph_host_bottom_margin);
    self.graph = [[CPTXYGraph alloc]initWithFrame:graph_frame];
    //设置画布主题
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [self.graph applyTheme:theme];
    //画布与周围的距离
    int hor_margin = -1;
    int ver_margin = -1;
    self.graph.paddingBottom = ver_margin;
    self.graph.paddingLeft = hor_margin;
    self.graph.paddingRight = hor_margin;
    self.graph.paddingTop = ver_margin;
    //将画布的坐标轴设为空
    self.graph.axisSet =nil;
    
    //创建画板
    CGRect graphhost_frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + graph_host_top_margin, self.view.bounds.size.width, self.view.bounds.size.height - graph_host_top_margin - graph_host_bottom_margin);
    CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc]initWithFrame:graphhost_frame];
    //设置画板的画布
    hostView.hostedGraph = self.graph;
    //设置画布标题的风格
    CPTMutableTextStyle *whiteText = [CPTMutableTextStyle textStyle];
    whiteText.color = [CPTColor blackColor];
    whiteText.fontSize = 16;
    whiteText.fontName = @"Helvetica-Bold";
    self.graph.titleTextStyle = whiteText;
    self.graph.title = @"运动统计";
    
    //创建饼图对象
    self.piePlot = [[CPTPieChart alloc]initWithFrame:CGRectMake(100,100,200,200)];
    //设置数据源
    self.piePlot.dataSource = self;
    //设置饼图半径
    self.piePlot.pieRadius = (self.view.frame.size.width - 130)/2;
    //设置饼图表示符
    self.piePlot.identifier = @"pie chart";
    //饼图开始绘制的位置
    self.piePlot.startAngle = M_PI_2 + M_PI_4;
    //饼图绘制的方向（顺时针/逆时针）
    self.piePlot.sliceDirection = CPTPieDirectionClockwise;
    //饼图的重心
    double pie_center_y = 0.55;
    if (self.displayLegend == 1) {
        pie_center_y = 0.58;
    }
    self.piePlot.centerAnchor = CGPointMake(0.5,pie_center_y);
    //饼图的线条风格
    self.piePlot.borderLineStyle = [CPTLineStyle lineStyle];
    //设置代理
    self.piePlot.delegate = self;
    //将饼图加到画布上
    [self.graph addPlot:self.piePlot];
    
    //将画板加到视图上
    [self.view addSubview:hostView];
    //NSLog(@"#######subview info: %@",self.view.subviews);
    //删除旧的画板
    while (self.view.subviews.count>1) {
        [[self.view.subviews objectAtIndex:0] removeFromSuperview];
    }
    //NSLog(@"#######subview info: %@",self.view.subviews);
    
    //创建图例
    CPTLegend *theLegend = [CPTLegend legendWithGraph:self.graph];
    theLegend.numberOfColumns = 4;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    theLegend.cornerRadius = 5.0;
    theLegend.delegate =self;
    
    if (self.displayLegend == 1) {
        self.graph.legend = theLegend;
        self.graph.legendAnchor = CPTRectAnchorBottom;
        self.graph.legendDisplacement = CGPointMake(0,2);
    }
}

- (void) setGraphTitle {
    NSString* display_cate;
    NSString* display_unit;
    int basicCalFlag = 1;
    switch (self.dataSel) {
        case 0:
            display_unit = @"分钟";
            display_cate = @"时间";
            basicCalFlag = 0;
            break;
        case 1:
            display_unit = @"大卡";
            display_cate = @"热量";
            break;
            
        default:
            break;
    }
    self.graph.title = [NSString stringWithFormat:@"运动消耗 %@ 总计: %.1f%@",display_cate,(self.arrSum + 2 * self.arrNegSum),display_unit];
    
    if (basicCalFlag == 1) {
        [self setBasicCaloriesLabel];
    }
}

- (void) setButton {
    int btn_width = 50;
    int btn_height = 50;
    int btn_x = self.view.frame.size.width - 8 - btn_width;
    int btn_y = 64 + 10;
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(btn_x,btn_y,btn_width,btn_height)];
    NSString* display_cate;
    switch (self.dataSel) {
        case 0:
            display_cate = @"热量";
            break;
        case 1:
            display_cate = @"时间";
            break;
            
        default:
            break;
    }
    UIFont* title_font = [UIFont boldSystemFontOfSize:12];
    btn.titleLabel.font = title_font;
    [btn setTitle:[NSString stringWithFormat:@"统计%@",display_cate] forState:UIControlStateNormal];
    // 设置边框
    UIColor* btnBorderColor = [UIColor colorWithRed:buttonBorderColorRGB[0]/255.0 green:buttonBorderColorRGB[1]/255.0 blue:buttonBorderColorRGB[2]/255.0 alpha:1.0];
    [btn.layer setBorderWidth:1];
    [btn.layer setBorderColor:btnBorderColor.CGColor];
    // 设置文字
    UIColor* btnTextColor = [UIColor colorWithRed:buttonTextColorRGB[0]/255.0 green:buttonTextColorRGB[1]/255.0 blue:buttonTextColorRGB[2]/255.0 alpha:1.0];
    [btn setTitleColor:btnTextColor forState:UIControlStateNormal];
    // 设置背景色
    UIColor* btnBGColor = [UIColor colorWithRed:buttonBGColorRGB[0]/255.0 green:buttonBGColorRGB[1]/255.0 blue:buttonBGColorRGB[2]/255.0 alpha:1.0];
    [btn setBackgroundColor:btnBGColor];
    
    btn.layer.cornerRadius = 25.0;
    
    [btn addTarget:self action:@selector(buttonToucheUpInside) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
}

- (void) setBasicCaloriesLabel {
    // 计算基础代谢值
//    NSLog(@"gender--%@,birthdate--%@,height--%@,weight--%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"gender"],[[NSUserDefaults standardUserDefaults] objectForKey:@"birthdate"],[[NSUserDefaults standardUserDefaults] objectForKey:@"height"],[[NSUserDefaults standardUserDefaults] objectForKey:@"weight"]);
    
    // 根据不同的性别、年龄、身高、体重计算基础代谢值
    int basicCal = 0;
    // 性别
    int gender = [[[NSUserDefaults standardUserDefaults] objectForKey:@"gender"] intValue];
    // 年龄
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date_now = [NSDate date];
    NSDate* date_birth = [dateFormat dateFromString:[[NSUserDefaults standardUserDefaults] objectForKey:@"birthdate"]];
    NSTimeInterval timeInterval = [date_now timeIntervalSinceDate:date_birth];
    int age = (int)(timeInterval/365/24/3600);
    // 身高
    int height = [[[NSUserDefaults standardUserDefaults] objectForKey:@"height"] intValue];
    // 体重
    int weight = [[[NSUserDefaults standardUserDefaults] objectForKey:@"weight"] intValue];
    NSLog(@"gender--%d,age--%d,height--%d,weight--%d",gender,age,height,weight);
    if (gender == 0) {
        // case: 男性
        basicCal = (int)(66 + 13.7 * weight + 5.0 * height - 6.8 * age);
    } else {
        // case: 女性
        basicCal = (int)(655 + 9.6 * weight + 1.7 * height - 4.7 * age);
    }
    
    // 初始化label
    UILabel* basicCaloriesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, graph_host_top_margin + 20, self.view.frame.size.width, 20)];
    
    // 设置label显示内容
    [basicCaloriesLabel setText:[NSString stringWithFormat:@"基础代谢消耗热量 %d 大卡/天",basicCal]];
    [basicCaloriesLabel setTextColor:[UIColor grayColor]];
    [basicCaloriesLabel setFont:[UIFont systemFontOfSize:12]];
    // 居中
    [basicCaloriesLabel setTextAlignment:NSTextAlignmentCenter];
    
    // 加入self.view.subviews
    [self.view addSubview:basicCaloriesLabel];
}

/*
 *  没有数据时，显示“暂无数据”
 */
- (void) displayNoDataInfo {
    // 添加textview
    double tv_x = 0;
    double tv_w = self.view.frame.size.width;
    double tv_h = 60;
    double tv_y = (self.view.frame.size.height - tv_h - graph_host_top_margin - graph_host_bottom_margin)/2 + graph_host_top_margin;
    UILabel* nodata_info = [[UILabel alloc] initWithFrame:CGRectMake(tv_x, tv_y, tv_w, tv_h)];
    // 文字颜色
    [nodata_info setTextColor:[UIColor grayColor]];
    // 文字字体
    [nodata_info setFont:[UIFont systemFontOfSize:40]];
    // 文字内容
    [nodata_info setText:@"暂无数据"];
    // 属性
    [nodata_info setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:nodata_info];
    
    //NSLog(@"self.view.subviews=%@",self.view.subviews);
    
    // 删除其他的subview
    while (self.view.subviews.count>1) {
        [[self.view.subviews objectAtIndex:0] removeFromSuperview];
    }
    
    //NSLog(@"self.view.subviews=%@",self.view.subviews);
}

- (void) buttonToucheUpInside {
    switch (self.dataSel) {
        case 0:
            self.dataSel = 1;
            break;
        case 1:
            self.dataSel = 0;
            break;
            
        default:
            break;
    }
    [self draw];
}

- (void) draw {
    NSInteger idx = self.timeSel;
    NSLog(@"draw, idx=%ld",(long)idx);
    switch (idx) {
        case 0:
            [self getActInfoDay:0];
            break;
        case 1:
            [self getActInfoWeek:0];
            break;
        case 2:
            [self getActInfoMonth:0];
            break;
        case 3:
            [self getActInfoYear:0];
            break;
        case -1:
            [self getActInfoSelectDay];
            break;
        default:
            break;
    }
    
    //NSLog(@"allActArr=%@",self.allActArr);
    if ([self.allActArr count] > 0) {
        [self mergePiePlotInfo];
        [self pieChartPlot];
        [self setButton];
        [self setGraphTitle];
    } else {
        [self displayNoDataInfo];
    }
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    NSLog(@"#=#=#=#=#=# segmentChanged!!");
    self.timeSel = sender.selectedSegmentIndex;
    [self draw];
}

- (IBAction)doSelectDate:(UIBarButtonItem *)sender {
    SelectDateViewController* selDateVc = [[SelectDateViewController alloc] init];
    selDateVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.navigationController presentViewController:selDateVc animated:YES completion:nil];
}

#pragma ===========================CPTPlotDelegate========================
//返回扇形数目
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.arr.count;
}
//返回每个扇形的比例
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    double ret = [[[self.arr objectAtIndex:idx] objectForKey:@"stat_value_abs"]doubleValue]/self.arrSum;
    return [[NSNumber alloc]initWithDouble:ret];
}
//凡返回每个扇形的标题
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    double stat_value = [[[self.arr objectAtIndex:idx] objectForKey:@"stat_value"] doubleValue];
    NSString* title_suffix;
    switch (self.dataSel) {
        case 0:
            title_suffix = @"分钟";
            break;
        case 1:
            title_suffix = @"大卡";
            
        default:
            break;
    }
    NSString* act_name = [[self.arr objectAtIndex:idx]objectForKey:@"name"];
    NSString* act_name_multiline = [act_name stringByReplacingOccurrencesOfString:@"(" withString:@"\n("];
    NSString* display_name = act_name;
    if ([act_name length] > 6) {
        display_name = act_name_multiline;
    }
    //NSLog(@"act_name=%@, act_name.len=%d, act_name_multiline=%@", act_name, [act_name length], act_name_multiline);
    CPTTextLayer *label = [[CPTTextLayer alloc]initWithText:[NSString stringWithFormat:@"%@\n%.1f%@",display_name, stat_value, title_suffix]];
    
    CPTMutableTextStyle *text = [label.textStyle mutableCopy];
    text.color = [CPTColor whiteColor];
    return label;
}

#pragma ===========CPTPieChart   Delegate========================
//选中某个扇形时的操作
- (void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)idx
{
    //self.graph.title = [NSString stringWithFormat:@"%@",[[self.arr objectAtIndex:idx] objectForKey:@"name"]];
}

//返回图例
- (NSAttributedString *)attributedLegendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    NSString* act_name = [[self.arr objectAtIndex:idx]objectForKey:@"name"];
    NSString* act_name_multiline = [act_name stringByReplacingOccurrencesOfString:@"(" withString:@"\n("];
    NSString* display_name = act_name_multiline;
   
    NSAttributedString *title = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",display_name]];
    
    return title;
}

// 返回每个扇形的填充颜色
- (CPTFill*) sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    NSLog(@"pieFillColorSize=%d",pieFillColorSize);
    int i = idx % pieFillColorSize;
    int loop = (int)idx / pieFillColorSize;
    int loopInterval = 31;
    int r = ((pieFillColorRGB[3 * i] + 256 - loop * loopInterval) % 256);
    int g = ((pieFillColorRGB[3 * i + 1] + 256 - loop * loopInterval) % 256);
    int b = ((pieFillColorRGB[3 * i + 2] + 256 - loop * loopInterval) % 256);
    NSLog(@"RGB=(%d,%d,%d)",r,g,b);
    double red = r / 255.0;
    double green = g / 255.0;;
    double blue = b / 255.0;;
    return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:red green:green blue:blue alpha:1]];
}

@end
