//
//  ActQueryAddViewController.h
//  Macaca
//  添加运动记录：开始时间、结束时间
//  Created by Julie on 15/1/15.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActQueryAddViewControllerDelegate <NSObject>

- (void)didPopToActQueryViewControllerAdd: (NSDate*)date;

@end

@interface ActQueryAddViewController : UIViewController

@property (nonatomic, retain) id <ActQueryAddViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString* sort; // 运动类别

@property (nonatomic, strong) NSDictionary* data; // 添加运动的具体信息：图片 名称等

@property (nonatomic, strong) NSString* dateStr; // 添加日期

@property (nonatomic, strong) NSMutableArray* acts; // 添加日期对应的运动数据

//@property (nonatomic, strong) NSDictionary* dict; // 用到的日期及对应运动数据(没用了)

@end
