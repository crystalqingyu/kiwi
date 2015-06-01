//
//  ActQueryEditViewController.h
//  Macaca
//
//  Created by Julie on 15/1/15.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActQueryEditViewControllerDelegate <NSObject>

- (void)didPopToActQueryViewControllerDelete: (NSDate*)date;
- (void)didPopToActQueryViewControllerEdit: (NSDate*)date;

@end

@interface ActQueryEditViewController : UIViewController

@property (nonatomic, strong) UITableViewCell* cell;
@property (nonatomic, strong) UITableViewCell* lastCell; // 上一个运动的cell，为了修改运动时间限制
@property (nonatomic, strong) UITableViewCell* nextCell; // 下一个运动的cell，为了修改运动时间限制
@property (nonatomic, strong) NSString* dateStr; // 修改运动的文件日期
@property (nonatomic, retain) id <ActQueryEditViewControllerDelegate> delegate;

@end
