//
//  SettingBaseViewController.m
//  Macaca
//
//  Created by Julie on 14/12/12.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "SettingBaseViewController.h"
#import "GroupSetting.h"
#import "SettingItem.h"
#import "ArrowSettingItem.h"
#import "GuideViewController.h"

@interface SettingBaseViewController ()

@end

@implementation SettingBaseViewController

- (id)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray*)data {
    if (_data==nil) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count;;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_data[section] settingGroup] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* ID = @"SettingCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    // 取出对应数据
    SettingItem* item = [_data[indexPath.section] settingGroup][indexPath.row];
    // 为cell赋值
    if ([item isKindOfClass:[ArrowSettingItem class]]) {
        cell.textLabel.text = item.text;
        cell.detailTextLabel.text = item.detailText;
        cell.imageView.image = [UIImage imageNamed:item.icon];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.data[section] title];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [self.data[section] footer];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 取出对应数据
    SettingItem* item = [_data[indexPath.section] settingGroup][indexPath.row];
    // 具体操作
    if (item.option!=nil) {
        item.option();
    }else if ([item isKindOfClass:[ArrowSettingItem class]]) {
        ArrowSettingItem* arrowItem = (ArrowSettingItem*)item;
        if (arrowItem.desClass==nil) {
            return;
        }
        if (arrowItem.desClass == [GuideViewController class]) { // 新手指引
            GuideViewController* guideVc=[self.storyboard instantiateViewControllerWithIdentifier:@"guideViewController"];
            guideVc.title = @"新手指引";
            [self.navigationController pushViewController:guideVc animated:YES];
        } else { // 其他
            [self.navigationController pushViewController:[[arrowItem.desClass alloc] init] animated:YES];
        }
    }
}


@end
