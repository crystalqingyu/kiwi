//
//  ActFullViewController.m
//  Macaca
//
//  Created by Julie on 15/1/8.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "ActFullViewController.h"
#import "ActFullSortViewController.h"
#import "ActSettingViewController.h"
#import "ActQueryAddViewController.h"

@interface ActFullViewController ()
@property (strong, nonatomic) IBOutlet UISearchBar *actSearchBar;

@end

@implementation ActFullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.actSearchBar.showsCancelButton = YES;
    //self.actSearchBar.showsBookmarkButton = YES;
    //    searchBar.barStyle = UIBarStyleBlack;
    //self.actSearchBar.translucent = YES;
    //self.actSearchBar.barStyle = UIBarStyleBlackTranslucent;
    //self.actSearchBar.tintColor = [UIColor redColor];
    //self.actSearchBar.prompt = @"搜索";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 从json文件中导入数据：act_full.json
- (NSMutableArray*)data {
    if (_data==nil) {
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
        // 将数组中字典添加到数据源_data中
        NSMutableArray* dataMutableArray = [NSMutableArray array];
        for (NSDictionary* dict in dataArray) {
            [dataMutableArray addObject:dict];
        }
        _data = dataMutableArray;
    }
    return _data;
}

// 从_data中导入搜索栏数据
- (NSMutableArray*)dataBase {
    if (_dataBase==nil) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        for (NSDictionary* dictSort in self.data) {
            for (NSDictionary* dictDetail in [dictSort objectForKey:@"act"]) {
                [array addObject:dictDetail];
            }
        }
        _dataBase = array;
    }
    return _dataBase;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.data.count;
    }else{
        // 谓词搜索
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains [cd] %@",_actSearchBar.text];
        // 搜索数组建立
        NSMutableArray* dataBaseName = [NSMutableArray array];
        for (NSDictionary* dict in self.dataBase) {
            [dataBaseName addObject:[dict objectForKey:@"title"]];
        }
        _dataFilter =  [[NSMutableArray alloc] initWithArray:[dataBaseName filteredArrayUsingPredicate:predicate]];
        return self.dataFilter.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"ActFullViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    cell.accessoryType = UITableViewCellAccessoryNone; // 恢复默认的cell状态
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    if (tableView != self.tableView) {
        // 取出对应数据
        NSString* title = self.dataFilter[indexPath.row];
        // 为cell赋值
        cell.textLabel.text = title;
    } else {
        // 取出对应数据
        NSDictionary* dict = _data[indexPath.row];
        // 为cell赋值
        cell.textLabel.text = dict[@"sort"];
    }
    // 设置cell
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

// 监控选择某一行跳入下一级控制器
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取消选中该行
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 判断是否应该跳到下一级控制器actFullSortViewController / 跳入actSetting或者actQueryAdd控制器
    if (tableView==self.tableView) { // actFullSortViewController
        // 取出对应数据
        NSDictionary* dict = _data[indexPath.row];
        // 执行segue
        [self performSegueWithIdentifier:@"JumpToActFullSort" sender:dict];
    } else { // actSettingViewController
        // 判断是活动记录这条线还是活动查询这条线
        if (self.tabBarController.selectedIndex==0) { // 活动记录这条线
            // 执行segue
            [self performSegueWithIdentifier:@"ActFullGoToActSetting" sender:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        } else { // 活动查询这条线——活动添加控制器
            // 执行segue
            [self performSegueWithIdentifier:@"ActFullGoToActQueryAdd" sender:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        }
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"JumpToActFullSort"]) {
        NSDictionary* dict = sender;
        ActFullSortViewController* desVc = segue.destinationViewController;
        desVc.data = [dict objectForKey:@"act"];
        desVc.sort = [dict objectForKey:@"sort"];
        desVc.currentAct = self.currentAct;
        desVc.dateStr = self.dateStr;
        desVc.acts = self.acts;
    } else if ([segue.identifier isEqualToString:@"ActFullGoToActQueryAdd"]) {
        NSString* text = sender;
        ActQueryAddViewController* desVc = segue.destinationViewController;
        desVc.dateStr = self.dateStr;
        desVc.acts = self.acts;
        // 赋值_data
        for (NSDictionary* dict in _data) {
            for (NSDictionary* dictInSort in dict[@"act"]) {
                if ([text isEqualToString: [dictInSort objectForKey:@"title"]]) {
                    desVc.data = dictInSort;
                    desVc.sort = [dict objectForKey:@"sort"];
                    break;
                }
            }
        }
    } else if ([segue.identifier isEqualToString:@"ActFullGoToActSetting"]) {
        NSString* text = sender;
        // 新控制器
        ActSettingViewController* desVc = segue.destinationViewController;
        // 设置标题
        desVc.title = text;
        // 赋值_data
        for (NSDictionary* dict in _data) {
            for (NSDictionary* dictInSort in dict[@"act"]) {
                if ([text isEqualToString: [dictInSort objectForKey:@"title"]]) {
                    desVc.data = dictInSort;
                    desVc.sort = [dict objectForKey:@"sort"];
                    break;
                }
            }
        }
        // 赋值_currentAct
        desVc.currentAct = self.currentAct;
    }
}

@end
