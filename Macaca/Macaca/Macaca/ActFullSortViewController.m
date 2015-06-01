//
//  ActFullSortViewController.m
//  Macaca
//
//  Created by Julie on 15/1/8.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "ActFullSortViewController.h"
#import "ActSettingViewController.h"
#import "ActQueryAddViewController.h"

@interface ActFullSortViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *actSearchBar;

@end

@implementation ActFullSortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.sort;
    self.actSearchBar.placeholder = [NSString stringWithFormat:@"搜索%@类运动",self.sort];
    self.actSearchBar.keyboardType = UIKeyboardTypeDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        for (NSDictionary* dict in self.data) {
            [dataBaseName addObject:[dict objectForKey:@"title"]];
        }
        _dataFilter =  [[NSMutableArray alloc] initWithArray:[dataBaseName filteredArrayUsingPredicate:predicate]];
        return self.dataFilter.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"ActFullSortViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
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
        cell.textLabel.text = dict[@"title"];
    }
    // 设置cell
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

// 监控点击某一行，跳入设置该运动控制器
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取消选中该行
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 判断是活动记录这条线还是活动查询这条线
    if (self.tabBarController.selectedIndex==0) {
        // 执行segue
        [self performSegueWithIdentifier:@"ActFullSortGoToActSetting" sender:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    } else {
        // 执行segue
        [self performSegueWithIdentifier:@"ActFullSortGoToActQueryAdd" sender:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ActFullSortGoToActQueryAdd"]) {
        NSString* text = sender;
        ActQueryAddViewController* desVc = segue.destinationViewController;
        desVc.dateStr = self.dateStr;
        desVc.acts = self.acts;
        desVc.sort = self.sort;
        // 设置_data
        for (NSDictionary* dict in _data) {
            if ([text isEqualToString: dict[@"title"]]) {
                desVc.data = dict;
                break;
            }
        }
    } else if ([segue.identifier isEqualToString:@"ActFullSortGoToActSetting"]) {
        NSString* text = sender;
        ActSettingViewController* desVc = segue.destinationViewController;
        // 设置标题、_currentAct、_sort
        desVc.title = text;
        desVc.currentAct = self.currentAct;
        desVc.sort = self.sort;
        // 设置_data
        for (NSDictionary* dict in _data) {
            if ([text isEqualToString: dict[@"title"]]) {
                desVc.data = dict;
                break;
            }
        }
    }
}

@end
