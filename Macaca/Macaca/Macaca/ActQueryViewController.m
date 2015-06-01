//
//  ActQueryViewController.m
//  Macaca
//
//  Created by Julie on 14/12/17.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "ActQueryViewController.h"
#import "DateChooseViewController.h"
#import "ActQueryViewCell.h"
#import "ActQueryAddViewController.h"
#import "ActQueryEditViewController.h"
#import "ActFullViewController.h"
#import "ActDataFile.h"

@interface ActQueryViewController () <DateChooseViewControllerDelegate,ActQueryEditViewControllerDelegate,ActQueryAddViewControllerDelegate, ActQueryViewCellDelegate>

- (IBAction)chooseDate:(UIBarButtonItem *)sender;
- (IBAction)deleteAct:(UIBarButtonItem *)sender;

@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSString* dateStr;
// 存储当前已被打开的 Cell 的列表
@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBtn;

@end

@implementation ActQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 保证了之后你可以正常使用数组
    self.cellsCurrentlyEditing = [NSMutableSet new];
}

// 显示控制器前最后调用，在代理后面，所以代理先为_date赋值
- (void)viewWillAppear:(BOOL)animated {
    // _date转化成字符串
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString* dateStr = [dateFormat stringFromDate:self.date];
    
    // 自定义navigationItem的titleView（防止改变标题后tabBar的title也跟着改变）
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor=[UIColor colorWithRed:255.0/255.0 green:253.0/255.0 blue:198.0/255.0 alpha:1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    if ([dateStr isEqualToString:[dateFormat stringFromDate:[NSDate date]]]) {
        titleLabel.text = @"今天";
    } else {
        // 设置title
        titleLabel.text = dateStr;
        // 根据给定日期设置表格内容
    }
    self.dateStr = dateStr; // 设置控制器标题字符串
    CGSize labSize = [titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:titleLabel.font, NSFontAttributeName, nil]];
    titleLabel.frame = CGRectMake(0, 0, labSize.width, labSize.height);
    titleLabel.center = CGPointMake(self.view.frame.size.width*0.5, self.navigationController.navigationBar.frame.size.height*0.5);

    self.navigationItem.titleView = titleLabel;
    
//    // 设置标题
//    if ([dateStr isEqualToString:[dateFormat stringFromDate:[NSDate date]]]) {
//        self.title = @"今天";
//    } else {
//        // 设置title
//        self.title = dateStr;
//        // 根据给定日期设置表格内容
//    }
    
    // 显示表格
    [self setCell:dateStr];
//    // _date赋值空以便下次默认显示为“今天”记录
//    _date = nil;
    // 设置“垃圾箱”按钮是否可用
    [self setDeleteBtn];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDate*)date {
    if (_date==nil) {
        _date = [NSDate date]; // 如果date为空，默认为今天
    }
    return _date;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* ID = @"ActQueryViewCell";
    static int labelTag = 1;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
//        cell = [ActQueryViewCell actQueryViewCell];
    }
    
    // 取出对应数据
    NSDictionary* dict = _data[indexPath.row];
    // 为cell赋值
    cell.textLabel.text = [dict objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@—%@",[dict objectForKey:@"firstTimeStr"],[dict objectForKey:@"endTimeStr"]];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // 添加calorie的label
    UILabel* label;
    if (cell.subviews.count==2) { // 之前没添加过label
        label = [ [ UILabel alloc ] initWithFrame: CGRectMake(self.view.frame.size.width*0.5, cell.frame.size.height*0.25, self.view.frame.size.width*0.35, cell.frame.size.height*0.5) ];
        label.tag = labelTag;
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:14];
        [cell addSubview:label];
    } else { // 已经存在label
        label = (UILabel*)[cell viewWithTag:labelTag];
    }
    NSString* finalCalorie = [self calculateCalorie:[dict objectForKey:@"firstTimeStr"] endTimeStr:[dict objectForKey:@"endTimeStr"] calorie:[dict objectForKey:@"calorie"]];
    label.text = [NSString stringWithFormat:@"%@大卡",finalCalorie];
//    cell.itemText = [dict objectForKey:@"name"];
//    cell.itemDetailText = [NSString stringWithFormat:@"%@—%@",[dict objectForKey:@"firstTimeStr"],[dict objectForKey:@"endTimeStr"]];

//    // 成为cell代理
//    cell.delegate = self;
    // 如果当前的 Cell 的 Index Path 在列表里，它就会将其设置为打开
//    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
//        [cell openCell];
//    }
    
//    // 测试代码
//    cell.backgroundColor = [UIColor purpleColor];
//    cell.contentView.backgroundColor = [UIColor blueColor];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//#ifdef DEBUG
//    NSLog(@"Cell recursive description:\n\n%@\n\n", [cell performSelector:@selector(recursiveDescription)]);
//#endif
//    for (UIView *view in cell.subviews) {
//        if ([view isKindOfClass:[UIScrollView class]]) {
//            view.backgroundColor = [UIColor greenColor];
//        }
//    }
    
    return cell;
}

// 监听选中某行操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取消选中
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 跳入新控制器：编辑活动记录
    [self performSegueWithIdentifier:@"GoToActQueryEdit" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

// 监听日期选择按钮
- (IBAction)chooseDate:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"GoToDateChoose" sender:nil];
}

// 监听垃圾桶按钮：删除运动
- (IBAction)deleteAct:(UIBarButtonItem *)sender {
    BOOL result = !self.tableView.editing;
    [self.tableView setEditing:result animated:YES];
}

// 监听添加按钮：添加运动
- (void)clickAdd {
    [self performSegueWithIdentifier:@"ActQueryGoToActFull" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GoToDateChoose"]) {
        DateChooseViewController* vc = segue.destinationViewController;
        vc.chooseDate = self.date;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"GoToActQueryEdit"]) {
        ActQueryEditViewController* vc = segue.destinationViewController;
        vc.cell = sender;
        vc.lastCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self.tableView indexPathForCell:sender].row-1) inSection:[self.tableView indexPathForCell:sender].section]];
        vc.nextCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self.tableView indexPathForCell:sender].row+1) inSection:[self.tableView indexPathForCell:sender].section]];
        vc.dateStr = self.dateStr;
        vc.delegate = self;
    } else {
        ActFullViewController* vc = segue.destinationViewController;
        vc.dateStr = self.dateStr;
        vc.acts = self.data;
    }
}

// DateChooseViewController代理，返回当前控制器后
- (void)didPopToActQueryViewController:(NSDate *)date{
    // 将返回日期赋值给控制器属性
    self.date = date;
}

// ActQueryEditViewController代理，返回当前控制器后显示对应日期数据，并删除相应行
- (void)didPopToActQueryViewControllerDelete: (NSDate *)date {
    self.date = date;
}

// ActQueryEditViewController代理，返回当前控制器后显示对应日期数据，并修改相应行
- (void)didPopToActQueryViewControllerEdit:(NSDate *)date {
    self.date = date;
}

// ActQueryAddViewController代理，返回当前控制器后显示对应日期数据，并添加相应记录
- (void)didPopToActQueryViewControllerAdd:(NSDate *)date {
    self.date = date;
}

// 根据给定日期设置表格内容
- (void)setCell: (NSString*)dateStr {
    // tableView更新列出文件中当天运动记录
    // 生成需要打开的文件路径
    NSString* home = NSHomeDirectory(); // 路径
    NSString* docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString* filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",[dateStr substringToIndex:7]]];
    // 字典中key
    NSString* day = [NSString stringWithFormat:@"%@",[dateStr substringFromIndex:8]];
    // 提取当月当天记录为数据源
    self.data = [[NSDictionary dictionaryWithContentsOfFile:filePath] objectForKey:day];
    // 更新表格
    [self.tableView reloadData];
}

//代理方法：删除数据
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除数据源
        [self.data removeObjectAtIndex:indexPath.row];
        //刷新表格
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        // 存储
        ActDataFile* file = [[ActDataFile alloc] init];
        file.actData = self.data;
        file.dateStr = self.dateStr;
        [file saveWithActData];
        // 设置垃圾箱按钮是否可用
        [self setDeleteBtn];
    } else {
        return;
    }
//    // 测试代码
//#ifdef DEBUG
//    NSLog(@"Cell recursive description:\n\n%@\n\n", [[tableView cellForRowAtIndexPath:indexPath] performSelector:@selector(recursiveDescription)]);
//#endif
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"willBeginEditing");
    
}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didEndEditing");
}
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return NO;// 为了防止跟自定义手势冲突！
//}
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
// 设置header图片，覆盖前面的titleForHeader
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // 添加button并且设置button文字与颜色等
    UIButton* btnAdd = [[UIButton alloc] init];
    btnAdd.layer.cornerRadius = 7;
    btnAdd.backgroundColor = [UIColor colorWithRed:255.0/255 green:251.0/255 blue:103.0/255 alpha:1];
    [btnAdd setTitle:@"运动" forState:UIControlStateNormal];
    [btnAdd setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnAdd.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //btnAdd.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [btnAdd setImage:[UIImage imageNamed:@"add@2x.png"] forState:UIControlStateNormal];//给button添加image
    btnAdd.imageEdgeInsets = UIEdgeInsetsMake(0,self.view.frame.size.width/320*280,0,0);//设置image在button上的位置（上top，左left，下bottom，右right）这里可以写负值，对上写－5，那么image就象上移动5个像素
    // 按钮添加监听事件
    [btnAdd addTarget:self action:@selector(clickAdd) forControlEvents:UIControlEventTouchUpInside];
    return btnAdd;
}
// 设置header的高度，一定要有，否则没有header图片显示！！！
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.view.frame.size.height*0.05;
}

// 根据firstTimeStr和endTimeStr和calorie计算消耗热量
- (NSString*)calculateCalorie: (NSString*)firstTimeStr endTimeStr: (NSString*)endTimeStr calorie: (NSString*)calorie {
    NSString* finalCalorie;
    double minInterval = [self minuteElapsedFrom:firstTimeStr to:endTimeStr]; // 间隔分钟数
    double finalCalorieDouble = (double)(minInterval*[calorie doubleValue]/60);
    finalCalorie = [NSString stringWithFormat:@"%.1f",finalCalorieDouble];
    return finalCalorie;
}
// 根据start和end字符串（格式HH:MM:SS）计算相隔时间，单位分钟
- (double) minuteElapsedFrom:(NSString*) start to:(NSString*) end {
    
    int sec_minus = [[end substringWithRange:NSMakeRange(6, 2)] intValue] - [[start substringWithRange:NSMakeRange(6, 2)] intValue];
    int min_minus = [[end substringWithRange:NSMakeRange(3, 2)] intValue] - [[start substringWithRange:NSMakeRange(3, 2)] intValue];
    int hour_minus = [[end substringWithRange:NSMakeRange(0, 2)] intValue] - [[start substringWithRange:NSMakeRange(0, 2)] intValue];
    return (hour_minus * 3600 + min_minus * 60 + sec_minus)/60.0;
}

- (void)setDeleteBtn {
    // 设置“垃圾箱”是否可以使用
    if (self.data.count==0) {
        self.deleteBtn.enabled = NO;
        [self.deleteBtn setTintColor:[UIColor yellowColor]];
    } else {
        self.deleteBtn.enabled = YES;
        // 还原本身的tintColor
        [self.deleteBtn setTintColor:[UIColor redColor]];
    }
}

//// ActQueryViewCell代理：监听删除与分解按钮
//- (void)buttonDeleteActionForItemText:(NSString *)itemText cell:(UITableViewCell *)cell {
//    // 获取cell的路径
//    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
//    // 恢复cell关闭状态，以便重新利用 (不确定是不是这么写！)
//    [self cellDidClose:[self.tableView cellForRowAtIndexPath:indexPath]];
//    [[self.tableView cellForRowAtIndexPath:indexPath] prepareForReuse];
//    // 删除数据源
//    NSLog(@"%d",indexPath.row);
//    [_data removeObjectAtIndex:indexPath.row];
//    // 刷新表格
//    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//    // 数据源归档
//        // _date转化成字符串
//    if (self.date == nil) {
//        self.date = [NSDate date];
//    }
//    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd"];
//    NSString* dateStr = [dateFormat stringFromDate:_date];
//        // 生成需要打开的文件路径
//    NSString* home = NSHomeDirectory(); // 路径
//    NSString* docPath = [home stringByAppendingPathComponent:@"Documents"];
//    NSString* filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",[dateStr substringToIndex:7]]];
//        // 字典中key
//    NSString* day = [NSString stringWithFormat:@"%@",[dateStr substringFromIndex:8]];
//         // 将整天记录_data写入文件
//    [[NSDictionary dictionaryWithObjectsAndKeys:_data,day,nil] writeToFile:filePath atomically:YES];
//}
//- (void)buttonExplodeActionForItemText:(NSString *)itemText cell:(UITableViewCell *)cell {
//    NSLog(@"In the delegate, Clicked button explode for %@", itemText);
//    NSLog(@"section:%d,row:%d",[self.tableView indexPathForCell:cell].section,[self.tableView indexPathForCell:cell].row);
//}
//- (void)cellDidOpen:(UITableViewCell *)cell {
//    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
//    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
//}
//- (void)cellDidClose:(UITableViewCell *)cell {
//    [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
//}
@end
