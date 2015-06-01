//
//  ActFullSortViewController.h
//  Macaca
//
//  Created by Julie on 15/1/8.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActFullSortViewController : UITableViewController

@property (nonatomic, copy) NSString* sort; // 运动类别

@property (nonatomic, strong) NSMutableArray* data; // 详细运动信息数组

@property (nonatomic, strong) NSMutableArray* dataFilter; // 过滤后的数据

@property (nonatomic, weak) NSString* currentAct; // 当前正在进行的运动，活动记录这条线用得到

@property (nonatomic, strong) NSString* dateStr; // 添加日期

@property (nonatomic, strong) NSMutableArray* acts; // 添加日期对应的运动数据

//@property (nonatomic, strong) NSDictionary* dict; // 用到的日期及对应运动数据(没用了)

@end
